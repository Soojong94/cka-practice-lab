#!/bin/bash
# Problem 030: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q030"
PASS=0
TOTAL=0

check_cluster

# 현재 노드 이름
NODE_NAME=$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')

# Task 1: manual-schedule-pod Running 상태
TOTAL=$((TOTAL+1))
POD1_STATUS=$(kubectl -n "$NAMESPACE" get pod manual-schedule-pod -o jsonpath='{.status.phase}' 2>/dev/null)
if [ "$POD1_STATUS" = "Running" ]; then
  print_pass "Task 1: Pod 'manual-schedule-pod' Running 상태"
  PASS=$((PASS+1))
else
  print_fail "Task 1: Pod 'manual-schedule-pod' Running 아님 (현재: $POD1_STATUS)" "nodeSelector를 수정하거나 nodeName을 지정하세요"
fi

# Task 2: manual-schedule-pod가 올바른 노드에 스케줄링됨
TOTAL=$((TOTAL+1))
POD1_NODE=$(kubectl -n "$NAMESPACE" get pod manual-schedule-pod -o jsonpath='{.spec.nodeName}' 2>/dev/null)
if [ "$POD1_NODE" = "$NODE_NAME" ]; then
  print_pass "Task 2: Pod 'manual-schedule-pod' 올바른 노드에 스케줄링됨 ($NODE_NAME)"
  PASS=$((PASS+1))
else
  print_fail "Task 2: Pod 'manual-schedule-pod' 노드 불일치 (현재: $POD1_NODE, 기대: $NODE_NAME)" "ConfigMap cluster-info에서 노드 이름을 확인하세요"
fi

# Task 3: normal-pod 존재 및 Running 상태
TOTAL=$((TOTAL+1))
POD2_STATUS=$(kubectl -n "$NAMESPACE" get pod normal-pod -o jsonpath='{.status.phase}' 2>/dev/null)
if [ "$POD2_STATUS" = "Running" ]; then
  print_pass "Task 3: Pod 'normal-pod' Running 상태"
  PASS=$((PASS+1))
else
  print_fail "Task 3: Pod 'normal-pod' Running 아님 (현재: $POD2_STATUS)" "normal-pod를 생성하세요"
fi

# Task 4: normal-pod가 올바른 노드에 스케줄링됨
TOTAL=$((TOTAL+1))
POD2_NODE=$(kubectl -n "$NAMESPACE" get pod normal-pod -o jsonpath='{.spec.nodeName}' 2>/dev/null)
if [ "$POD2_NODE" = "$NODE_NAME" ]; then
  print_pass "Task 4: Pod 'normal-pod' 올바른 노드에 스케줄링됨 ($NODE_NAME)"
  PASS=$((PASS+1))
else
  print_fail "Task 4: Pod 'normal-pod' 노드 불일치 (현재: $POD2_NODE, 기대: $NODE_NAME)" "scheduler가 자동으로 스케줄링합니다"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
