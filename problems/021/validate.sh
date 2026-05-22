#!/bin/bash
# Problem 021: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q021"
PASS=0
TOTAL=0

check_cluster

# Task 1: ConfigMap 존재 여부
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get configmap qos-analysis &>/dev/null; then
  print_pass "Task 1: ConfigMap 'qos-analysis' 존재"
  PASS=$((PASS+1))
else
  print_fail "Task 1: ConfigMap 'qos-analysis' 미생성" "kubectl create configmap qos-analysis 명령을 사용하세요"
fi

# Task 2: guaranteed 값 확인
TOTAL=$((TOTAL+1))
GUARANTEED_VAL=$(kubectl -n "$NAMESPACE" get configmap qos-analysis -o jsonpath='{.data.guaranteed}' 2>/dev/null)
if [ "$GUARANTEED_VAL" = "pod-guaranteed" ]; then
  print_pass "Task 2: 'guaranteed' 값 올바름 (pod-guaranteed)"
  PASS=$((PASS+1))
else
  print_fail "Task 2: 'guaranteed' 값 불일치 (현재: $GUARANTEED_VAL)" "Guaranteed QoS Pod 이름을 확인하세요"
fi

# Task 3: first-terminated 값 확인
TOTAL=$((TOTAL+1))
FIRST_TERM=$(kubectl -n "$NAMESPACE" get configmap qos-analysis -o jsonpath='{.data.first-terminated}' 2>/dev/null)
if [ "$FIRST_TERM" = "pod-besteffort" ]; then
  print_pass "Task 3: 'first-terminated' 값 올바름 (pod-besteffort)"
  PASS=$((PASS+1))
else
  print_fail "Task 3: 'first-terminated' 값 불일치 (현재: $FIRST_TERM)" "BestEffort Pod가 가장 먼저 종료됩니다"
fi

# Task 4: eviction-order 값 확인
TOTAL=$((TOTAL+1))
EVICTION=$(kubectl -n "$NAMESPACE" get configmap qos-analysis -o jsonpath='{.data.eviction-order}' 2>/dev/null)
if echo "$EVICTION" | grep -qi "besteffort" && echo "$EVICTION" | grep -qi "burstable" && echo "$EVICTION" | grep -qi "guaranteed"; then
  print_pass "Task 4: 'eviction-order' 값에 올바른 순서 포함"
  PASS=$((PASS+1))
else
  print_fail "Task 4: 'eviction-order' 값 불일치 (현재: $EVICTION)" "BestEffort -> Burstable -> Guaranteed 순서를 작성하세요"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
