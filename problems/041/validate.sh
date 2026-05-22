#!/bin/bash
# Problem 041: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q041"
PASS=0
TOTAL=0

check_cluster

# Task 1: DaemonSet 존재 여부 및 레이블 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get ds ds-important &>/dev/null; then
  IMAGE=$(kubectl -n "$NAMESPACE" get ds ds-important -o jsonpath='{.spec.template.spec.containers[0].image}')
  LABEL=$(kubectl -n "$NAMESPACE" get ds ds-important -o jsonpath='{.spec.template.metadata.labels.id}')
  if [ "$IMAGE" = "httpd:2-alpine" ] && [ "$LABEL" = "ds-important" ]; then
    print_pass "Task 1: DaemonSet 'ds-important' 올바르게 생성됨 (image=httpd:2-alpine, label id=ds-important)"
    PASS=$((PASS+1))
  else
    print_fail "Task 1: DaemonSet 스펙 불일치 (image=$IMAGE, label=$LABEL)" \
      "이미지 httpd:2-alpine, 레이블 id=ds-important 확인"
  fi
else
  print_fail "Task 1: DaemonSet 'ds-important' 미생성" "kubectl -n $NAMESPACE apply -f 로 DaemonSet을 생성하세요"
fi

# Task 2: 리소스 요청 확인
TOTAL=$((TOTAL+1))
CPU_REQ=$(kubectl -n "$NAMESPACE" get ds ds-important -o jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu}' 2>/dev/null)
MEM_REQ=$(kubectl -n "$NAMESPACE" get ds ds-important -o jsonpath='{.spec.template.spec.containers[0].resources.requests.memory}' 2>/dev/null)
if [ "$CPU_REQ" = "10m" ] && [ "$MEM_REQ" = "10Mi" ]; then
  print_pass "Task 2: 리소스 요청 올바르게 설정됨 (cpu=10m, memory=10Mi)"
  PASS=$((PASS+1))
else
  print_fail "Task 2: 리소스 요청 불일치 (cpu=$CPU_REQ, memory=$MEM_REQ)" \
    "resources.requests에 cpu: 10m, memory: 10Mi 설정"
fi

# Task 3: Toleration 확인
TOTAL=$((TOTAL+1))
TOLERATIONS=$(kubectl -n "$NAMESPACE" get ds ds-important -o jsonpath='{.spec.template.spec.tolerations}' 2>/dev/null)
if echo "$TOLERATIONS" | grep -q "node-role.kubernetes.io/control-plane"; then
  print_pass "Task 3: Control Plane toleration 설정됨"
  PASS=$((PASS+1))
else
  print_fail "Task 3: Control Plane toleration 미설정" \
    "tolerations에 key: node-role.kubernetes.io/control-plane 추가"
fi

# Task 4: 모든 노드에서 Pod Running 확인
TOTAL=$((TOTAL+1))
DESIRED=$(kubectl -n "$NAMESPACE" get ds ds-important -o jsonpath='{.status.desiredNumberScheduled}' 2>/dev/null)
READY=$(kubectl -n "$NAMESPACE" get ds ds-important -o jsonpath='{.status.numberReady}' 2>/dev/null)
if [ -n "$DESIRED" ] && [ "$DESIRED" -gt 0 ] && [ "$DESIRED" = "$READY" ]; then
  print_pass "Task 4: 모든 노드에서 Pod Running (desired=$DESIRED, ready=$READY)"
  PASS=$((PASS+1))
else
  print_fail "Task 4: Pod가 모든 노드에서 실행되지 않음 (desired=$DESIRED, ready=$READY)" \
    "DaemonSet Pod 상태를 확인하세요"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
