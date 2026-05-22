#!/bin/bash
# Problem 038: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q038"
PASS=0
TOTAL=0

check_cluster

NODE_NAME=$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')

# Task 1: 노드에 disk=ssd 레이블 존재 확인
TOTAL=$((TOTAL+1))
DISK_LABEL=$(kubectl get node "$NODE_NAME" -o jsonpath='{.metadata.labels.disk}' 2>/dev/null)
if [ "$DISK_LABEL" = "ssd" ]; then
  print_pass "Task 1: 노드 '$NODE_NAME'에 레이블 'disk=ssd' 존재"
  PASS=$((PASS+1))
else
  print_fail "Task 1: 노드 '$NODE_NAME'에 레이블 'disk=ssd' 없음 (현재: $DISK_LABEL)" \
    "kubectl label nodes $NODE_NAME disk=ssd"
fi

# Task 2: Pod 존재 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get pod ssd-pod &>/dev/null; then
  print_pass "Task 2: Pod 'ssd-pod' 존재"
  PASS=$((PASS+1))
else
  print_fail "Task 2: Pod 'ssd-pod' 미존재" \
    "Pod를 재생성하세요"
fi

# Task 3: Pod Running 상태 확인
TOTAL=$((TOTAL+1))
POD_PHASE=$(kubectl -n "$NAMESPACE" get pod ssd-pod -o jsonpath='{.status.phase}' 2>/dev/null)
if [ "$POD_PHASE" = "Running" ]; then
  print_pass "Task 3: Pod 'ssd-pod' Running 상태"
  PASS=$((PASS+1))
else
  print_fail "Task 3: Pod 'ssd-pod' Running 아님 (현재: $POD_PHASE)" \
    "nodeSelector와 toleration을 모두 설정하세요"
fi

# Task 4: Pod에 toleration 설정 확인
TOTAL=$((TOTAL+1))
TOLERATION_KEY=$(kubectl -n "$NAMESPACE" get pod ssd-pod -o jsonpath='{.spec.tolerations[?(@.key=="dedicated")].key}' 2>/dev/null)
TOLERATION_VALUE=$(kubectl -n "$NAMESPACE" get pod ssd-pod -o jsonpath='{.spec.tolerations[?(@.key=="dedicated")].value}' 2>/dev/null)
TOLERATION_EFFECT=$(kubectl -n "$NAMESPACE" get pod ssd-pod -o jsonpath='{.spec.tolerations[?(@.key=="dedicated")].effect}' 2>/dev/null)
if [ "$TOLERATION_KEY" = "dedicated" ] && [ "$TOLERATION_VALUE" = "special" ] && [ "$TOLERATION_EFFECT" = "NoSchedule" ]; then
  print_pass "Task 4: Pod에 toleration 'dedicated=special:NoSchedule' 설정됨"
  PASS=$((PASS+1))
else
  print_fail "Task 4: Pod에 toleration 미설정 또는 불일치 (key=$TOLERATION_KEY, value=$TOLERATION_VALUE, effect=$TOLERATION_EFFECT)" \
    "tolerations에 dedicated=special:NoSchedule을 추가하세요"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
