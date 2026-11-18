#!/bin/bash
# Problem 066: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q066"
PASS=0
TOTAL=0

check_cluster

# Task 1: 노드가 uncordon 상태 (최종 상태)
TOTAL=$((TOTAL+1))
NODE_NAME=$(kubectl -n "$NAMESPACE" get configmap drain-target -o jsonpath='{.data.node}' 2>/dev/null)
NODE_NAME=${NODE_NAME:-$(lab_node)}
NODE_SCHED=$(kubectl get node "$NODE_NAME" -o jsonpath='{.spec.unschedulable}' 2>/dev/null)
if [ "$NODE_SCHED" != "true" ]; then
  print_pass "Task 1: 노드 $NODE_NAME이 스케줄 가능 상태 (uncordoned)"
  PASS=$((PASS+1))
else
  print_fail "Task 1: 노드가 여전히 SchedulingDisabled 상태" \
    "kubectl uncordon $NODE_NAME"
fi

# Task 2: ConfigMap drain-verify의 node-cordoned 확인
TOTAL=$((TOTAL+1))
NODE_CORDONED=$(kubectl -n "$NAMESPACE" get configmap drain-verify -o jsonpath='{.data.node-cordoned}' 2>/dev/null)
if [ "$NODE_CORDONED" = "true" ]; then
  print_pass "Task 2: node-cordoned = true"
  PASS=$((PASS+1))
else
  print_fail "Task 2: node-cordoned 불일치 (현재: '$NODE_CORDONED')" \
    "cordon 후 ConfigMap에 true를 저장하세요"
fi

# Task 3: ConfigMap drain-verify의 node-uncordoned 확인
TOTAL=$((TOTAL+1))
NODE_UNCORDONED=$(kubectl -n "$NAMESPACE" get configmap drain-verify -o jsonpath='{.data.node-uncordoned}' 2>/dev/null)
if [ "$NODE_UNCORDONED" = "true" ]; then
  print_pass "Task 3: node-uncordoned = true"
  PASS=$((PASS+1))
else
  print_fail "Task 3: node-uncordoned 불일치 (현재: '$NODE_UNCORDONED')" \
    "uncordon 후 ConfigMap에 true를 저장하세요"
fi

# Task 4: Deployment web-app의 Pod가 Running 상태
TOTAL=$((TOTAL+1))
READY_PODS=$(kubectl -n "$NAMESPACE" get deployment web-app -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
if [ "$READY_PODS" = "2" ]; then
  print_pass "Task 4: Deployment 'web-app' Pod 2개 Running"
  PASS=$((PASS+1))
else
  print_fail "Task 4: Deployment 'web-app' Ready Pod 수 불일치 (현재: '$READY_PODS')" \
    "uncordon 후 Pod가 다시 스케줄되어야 합니다"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
