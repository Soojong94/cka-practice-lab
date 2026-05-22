#!/bin/bash
# Problem 089: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q089"
PASS=0
TOTAL=0

check_cluster

# Task 1: HTTPRoute 'api-routes' 존재 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get httproute api-routes &>/dev/null; then
  print_pass "Task 1: HTTPRoute 'api-routes' 존재"
  PASS=$((PASS+1))
else
  print_fail "Task 1: HTTPRoute 'api-routes' 미생성" \
    "HTTPRoute 리소스를 생성하세요"
fi

# Task 2: parentRefs 확인
TOTAL=$((TOTAL+1))
PARENT_REF=$(kubectl -n "$NAMESPACE" get httproute api-routes -o jsonpath='{.spec.parentRefs[0].name}' 2>/dev/null)
if [ "$PARENT_REF" = "api-gateway" ]; then
  print_pass "Task 2: parentRefs=api-gateway 올바름"
  PASS=$((PASS+1))
else
  print_fail "Task 2: parentRefs 불일치 (현재: $PARENT_REF)" \
    "spec.parentRefs[].name: api-gateway 확인"
fi

# Task 3: /v1 → svc-v1 규칙 확인
TOTAL=$((TOTAL+1))
ROUTE_JSON=$(kubectl -n "$NAMESPACE" get httproute api-routes -o json 2>/dev/null)
V1_PATH=$(echo "$ROUTE_JSON" | grep -o '"/v1"' | head -1)
V1_BACKEND=$(echo "$ROUTE_JSON" | grep -o '"svc-v1"' | head -1)
if [ -n "$V1_PATH" ] && [ -n "$V1_BACKEND" ]; then
  print_pass "Task 3: /v1 → svc-v1 경로 규칙 올바름"
  PASS=$((PASS+1))
else
  print_fail "Task 3: /v1 → svc-v1 규칙 미설정" \
    "matches[].path.value: /v1, backendRefs[].name: svc-v1 확인"
fi

# Task 4: /v2 → svc-v2 규칙 확인
TOTAL=$((TOTAL+1))
V2_PATH=$(echo "$ROUTE_JSON" | grep -o '"/v2"' | head -1)
V2_BACKEND=$(echo "$ROUTE_JSON" | grep -o '"svc-v2"' | head -1)
if [ -n "$V2_PATH" ] && [ -n "$V2_BACKEND" ]; then
  print_pass "Task 4: /v2 → svc-v2 경로 규칙 올바름"
  PASS=$((PASS+1))
else
  print_fail "Task 4: /v2 → svc-v2 규칙 미설정" \
    "matches[].path.value: /v2, backendRefs[].name: svc-v2 확인"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
