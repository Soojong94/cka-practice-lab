#!/bin/bash
# Problem 071: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q071"
PASS=0
TOTAL=0

check_cluster

# ConfigMap에서 webhook.yaml 내용 추출
WEBHOOK_YAML=$(kubectl -n "$NAMESPACE" get configmap webhook-config -o jsonpath='{.data.webhook\.yaml}' 2>/dev/null)

# Task 1: operations가 CREATE로 설정되었는지
TOTAL=$((TOTAL+1))
if echo "$WEBHOOK_YAML" | grep -q 'operations:.*\["CREATE"\]'; then
  print_pass "Task 1: operations가 CREATE로 설정됨"
  PASS=$((PASS+1))
else
  print_fail "Task 1: operations가 CREATE로 설정되지 않음" "operations: [\"CREATE\"]로 설정하세요"
fi

# Task 2: resources가 pods로 설정되었는지
TOTAL=$((TOTAL+1))
if echo "$WEBHOOK_YAML" | grep -q 'resources:.*\["pods"\]'; then
  print_pass "Task 2: resources가 pods로 설정됨"
  PASS=$((PASS+1))
else
  print_fail "Task 2: resources가 pods로 설정되지 않음" "resources: [\"pods\"]로 설정하세요"
fi

# Task 3: failurePolicy가 Ignore로 설정되었는지
TOTAL=$((TOTAL+1))
if echo "$WEBHOOK_YAML" | grep -q 'failurePolicy:.*Ignore'; then
  print_pass "Task 3: failurePolicy가 Ignore로 설정됨"
  PASS=$((PASS+1))
else
  print_fail "Task 3: failurePolicy가 Ignore로 설정되지 않음" "failurePolicy: Ignore로 설정하세요"
fi

# Task 4: sideEffects가 None으로 설정되었는지
TOTAL=$((TOTAL+1))
if echo "$WEBHOOK_YAML" | grep -q 'sideEffects:.*None'; then
  print_pass "Task 4: sideEffects가 None으로 설정됨"
  PASS=$((PASS+1))
else
  print_fail "Task 4: sideEffects가 None으로 설정되지 않음" "sideEffects: None으로 설정하세요"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
