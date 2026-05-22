#!/bin/bash
# Problem 011: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q011"
PASS=0
TOTAL=0

check_cluster

# Task 1: Pod 존재 여부 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get pod crash-pod &>/dev/null; then
  print_pass "Task 1: Pod 'crash-pod' 존재 확인"
  PASS=$((PASS+1))
else
  print_fail "Task 1: Pod 'crash-pod' 미존재" "Pod를 다시 생성하세요"
fi

# Task 2: Pod Running 상태 확인
TOTAL=$((TOTAL+1))
POD_STATUS=$(kubectl -n "$NAMESPACE" get pod crash-pod -o jsonpath='{.status.phase}' 2>/dev/null)
if [ "$POD_STATUS" = "Running" ]; then
  print_pass "Task 2: Pod 'crash-pod' Running 상태"
  PASS=$((PASS+1))
else
  print_fail "Task 2: Pod 'crash-pod' Running 아님 (현재: $POD_STATUS)" \
    "Pod의 command를 올바르게 수정하세요"
fi

# Task 3: 올바른 command 확인
TOTAL=$((TOTAL+1))
CMD=$(kubectl -n "$NAMESPACE" get pod crash-pod -o jsonpath='{.spec.containers[0].command[0]}' 2>/dev/null)
if [ "$CMD" = "sleep" ]; then
  print_pass "Task 3: 올바른 command 'sleep' 설정됨"
  PASS=$((PASS+1))
else
  print_fail "Task 3: command가 'sleep'이 아님 (현재: $CMD)" \
    "command를 ['sleep', '3600']으로 수정하세요"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
