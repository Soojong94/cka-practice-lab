#!/bin/bash
# Problem 067: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q067"
PASS=0
TOTAL=0

check_cluster

# Task 1: sorted-pods 확인 (생성 시간 순서)
TOTAL=$((TOTAL+1))
SORTED_PODS=$(kubectl -n "$NAMESPACE" get configmap kubectl-output -o jsonpath='{.data.sorted-pods}' 2>/dev/null)
# 실제 생성 순서 확인
EXPECTED_ORDER=$(kubectl -n "$NAMESPACE" get pods --sort-by=.metadata.creationTimestamp -o jsonpath='{.items[*].metadata.name}' | tr ' ' ',')
if [ "$SORTED_PODS" = "$EXPECTED_ORDER" ]; then
  print_pass "Task 1: sorted-pods 올바른 순서"
  PASS=$((PASS+1))
else
  print_fail "Task 1: sorted-pods 순서 불일치 (현재: '$SORTED_PODS', 기대: '$EXPECTED_ORDER')" \
    "--sort-by=.metadata.creationTimestamp 사용"
fi

# Task 2: custom-columns-cmd 확인
TOTAL=$((TOTAL+1))
CUSTOM_CMD=$(kubectl -n "$NAMESPACE" get configmap kubectl-output -o jsonpath='{.data.custom-columns-cmd}' 2>/dev/null)
if echo "$CUSTOM_CMD" | grep -q "custom-columns" && echo "$CUSTOM_CMD" | grep -q "metadata.name" && echo "$CUSTOM_CMD" | grep -q "podIP"; then
  print_pass "Task 2: custom-columns-cmd 올바른 형식"
  PASS=$((PASS+1))
else
  print_fail "Task 2: custom-columns-cmd 형식 불일치 (현재: '$CUSTOM_CMD')" \
    "kubectl -n cka-q067 get pods -o custom-columns=NAME:.metadata.name,IP:.status.podIP"
fi

# Task 3: pod-beta-tier 확인
TOTAL=$((TOTAL+1))
POD_BETA_TIER=$(kubectl -n "$NAMESPACE" get configmap kubectl-output -o jsonpath='{.data.pod-beta-tier}' 2>/dev/null)
if [ "$POD_BETA_TIER" = "backend" ]; then
  print_pass "Task 3: pod-beta-tier = backend"
  PASS=$((PASS+1))
else
  print_fail "Task 3: pod-beta-tier 불일치 (현재: '$POD_BETA_TIER')" \
    "kubectl -n cka-q067 get pod pod-beta -o jsonpath='{.metadata.labels.tier}'"
fi

# Task 4: backend-count 확인
TOTAL=$((TOTAL+1))
BACKEND_COUNT=$(kubectl -n "$NAMESPACE" get configmap kubectl-output -o jsonpath='{.data.backend-count}' 2>/dev/null)
if [ "$BACKEND_COUNT" = "2" ]; then
  print_pass "Task 4: backend-count = 2"
  PASS=$((PASS+1))
else
  print_fail "Task 4: backend-count 불일치 (현재: '$BACKEND_COUNT')" \
    "kubectl -n cka-q067 get pods -l tier=backend --no-headers | wc -l"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
