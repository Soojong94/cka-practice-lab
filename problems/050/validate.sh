#!/bin/bash
# Problem 050: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q050"
PASS=0
TOTAL=0

check_cluster

# Task 1: PriorityClass 존재 확인
TOTAL=$((TOTAL+1))
if kubectl get priorityclass high-priority &>/dev/null; then
  PC_VALUE=$(kubectl get priorityclass high-priority -o jsonpath='{.value}')
  if [ "$PC_VALUE" = "1000000" ]; then
    print_pass "Task 1: PriorityClass 'high-priority' 존재 (value=1000000)"
    PASS=$((PASS+1))
  else
    print_fail "Task 1: PriorityClass value 불일치 (현재: $PC_VALUE)" \
      "value: 1000000 확인"
  fi
else
  print_fail "Task 1: PriorityClass 'high-priority' 미존재" \
    "setup.sh를 다시 실행하세요"
fi

# Task 2: important-pod priorityClassName 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get pod important-pod &>/dev/null; then
  PC_NAME=$(kubectl -n "$NAMESPACE" get pod important-pod -o jsonpath='{.spec.priorityClassName}')
  if [ "$PC_NAME" = "high-priority" ]; then
    print_pass "Task 2: important-pod에 priorityClassName 'high-priority' 설정됨"
    PASS=$((PASS+1))
  else
    print_fail "Task 2: important-pod priorityClassName 불일치 (현재: $PC_NAME)" \
      "spec.priorityClassName: high-priority 설정"
  fi
else
  print_fail "Task 2: Pod 'important-pod' 미생성" "kubectl -n $NAMESPACE apply로 생성하세요"
fi

# Task 3: important-pod priority 값 확인
TOTAL=$((TOTAL+1))
PRIORITY=$(kubectl -n "$NAMESPACE" get pod important-pod -o jsonpath='{.spec.priority}' 2>/dev/null)
if [ "$PRIORITY" = "1000000" ]; then
  print_pass "Task 3: important-pod priority=1000000"
  PASS=$((PASS+1))
else
  print_fail "Task 3: important-pod priority 불일치 (현재: $PRIORITY)" \
    "priorityClassName을 설정하면 자동으로 priority 값이 할당됩니다"
fi

# Task 4: normal-pod 존재 및 priority 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get pod normal-pod &>/dev/null; then
  NORMAL_PRIORITY=$(kubectl -n "$NAMESPACE" get pod normal-pod -o jsonpath='{.spec.priority}')
  if [ "$NORMAL_PRIORITY" = "0" ]; then
    print_pass "Task 4: normal-pod priority=0 (기본값)"
    PASS=$((PASS+1))
  else
    print_fail "Task 4: normal-pod priority 불일치 (현재: $NORMAL_PRIORITY)" \
      "priorityClassName을 설정하지 않으면 기본 priority는 0입니다"
  fi
else
  print_fail "Task 4: Pod 'normal-pod' 미생성" "kubectl -n $NAMESPACE apply로 생성하세요"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
