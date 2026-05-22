#!/bin/bash
# Problem 079: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q079"
PASS=0
TOTAL=0

check_cluster

# ConfigMap에서 감사 정책 추출
POLICY_YAML=$(kubectl -n "$NAMESPACE" get configmap audit-policy -o jsonpath='{.data.policy\.yaml}' 2>/dev/null)

# Task 1: Secrets에 대한 RequestResponse 레벨 규칙
TOTAL=$((TOTAL+1))
if echo "$POLICY_YAML" | grep -q 'RequestResponse' && echo "$POLICY_YAML" | grep -q '"secrets"'; then
  print_pass "Task 1: Secrets에 대한 RequestResponse 레벨 규칙 설정됨"
  PASS=$((PASS+1))
else
  print_fail "Task 1: Secrets에 대한 RequestResponse 규칙 없음" "level: RequestResponse, resources: [\"secrets\"]로 설정하세요"
fi

# Task 2: Namespaces에 대한 Metadata 레벨 규칙
TOTAL=$((TOTAL+1))
if echo "$POLICY_YAML" | grep -q 'Metadata' && echo "$POLICY_YAML" | grep -q '"namespaces"'; then
  print_pass "Task 2: Namespaces에 대한 Metadata 레벨 규칙 설정됨"
  PASS=$((PASS+1))
else
  print_fail "Task 2: Namespaces에 대한 Metadata 규칙 없음" "level: Metadata, resources: [\"namespaces\"]로 설정하세요"
fi

# Task 3: Namespaces 규칙에 create, update, delete verbs가 있는지
TOTAL=$((TOTAL+1))
if echo "$POLICY_YAML" | grep -q '"create"' && echo "$POLICY_YAML" | grep -q '"update"' && echo "$POLICY_YAML" | grep -q '"delete"'; then
  print_pass "Task 3: Namespace 규칙에 create/update/delete verbs 포함"
  PASS=$((PASS+1))
else
  print_fail "Task 3: Namespace 규칙에 verbs 누락" "verbs: [\"create\", \"update\", \"delete\"]를 설정하세요"
fi

# Task 4: ConfigMaps에 대한 None 레벨 규칙
TOTAL=$((TOTAL+1))
if echo "$POLICY_YAML" | grep -q 'None' && echo "$POLICY_YAML" | grep -q '"configmaps"'; then
  print_pass "Task 4: ConfigMaps에 대한 None 레벨 규칙 설정됨"
  PASS=$((PASS+1))
else
  print_fail "Task 4: ConfigMaps에 대한 None 규칙 없음" "level: None, resources: [\"configmaps\"]로 설정하세요"
fi

# Task 5: ConfigMaps 규칙에 get, list, watch verbs가 있는지
TOTAL=$((TOTAL+1))
if echo "$POLICY_YAML" | grep -q '"get"' && echo "$POLICY_YAML" | grep -q '"list"' && echo "$POLICY_YAML" | grep -q '"watch"'; then
  print_pass "Task 5: ConfigMaps 규칙에 get/list/watch verbs 포함"
  PASS=$((PASS+1))
else
  print_fail "Task 5: ConfigMaps 규칙에 verbs 누락" "verbs: [\"get\", \"list\", \"watch\"]를 설정하세요"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
