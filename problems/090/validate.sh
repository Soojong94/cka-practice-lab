#!/bin/bash
# Problem 090: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q090"
PASS=0
TOTAL=0

check_cluster

# Task 1: HTTPRoute 'device-route' 존재 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get httproute device-route &>/dev/null; then
  print_pass "Task 1: HTTPRoute 'device-route' 존재"
  PASS=$((PASS+1))
else
  print_fail "Task 1: HTTPRoute 'device-route' 미생성" \
    "HTTPRoute 리소스를 생성하세요"
fi

# Task 2: parentRefs 확인
TOTAL=$((TOTAL+1))
PARENT_REF=$(kubectl -n "$NAMESPACE" get httproute device-route -o jsonpath='{.spec.parentRefs[0].name}' 2>/dev/null)
if [ "$PARENT_REF" = "header-gateway" ]; then
  print_pass "Task 2: parentRefs=header-gateway 올바름"
  PASS=$((PASS+1))
else
  print_fail "Task 2: parentRefs 불일치 (현재: $PARENT_REF)" \
    "spec.parentRefs[].name: header-gateway 확인"
fi

# Task 3: User-Agent 헤더 매칭 규칙 확인
TOTAL=$((TOTAL+1))
ROUTE_JSON=$(kubectl -n "$NAMESPACE" get httproute device-route -o json 2>/dev/null)
HAS_UA_HEADER=$(echo "$ROUTE_JSON" | grep -i "User-Agent" | head -1)
HAS_MOBILE_SVC=$(echo "$ROUTE_JSON" | grep -o '"mobile-svc"' | head -1)
if [ -n "$HAS_UA_HEADER" ] && [ -n "$HAS_MOBILE_SVC" ]; then
  print_pass "Task 3: User-Agent 헤더 매칭 → mobile-svc 규칙 존재"
  PASS=$((PASS+1))
else
  print_fail "Task 3: User-Agent 헤더 매칭 규칙 미설정" \
    "headers[].name: User-Agent, backendRefs: mobile-svc 확인"
fi

# Task 4: 기본 규칙 (desktop-svc) 확인
TOTAL=$((TOTAL+1))
HAS_DESKTOP_SVC=$(echo "$ROUTE_JSON" | grep -o '"desktop-svc"' | head -1)
if [ -n "$HAS_DESKTOP_SVC" ]; then
  print_pass "Task 4: 기본 라우팅 → desktop-svc 규칙 존재"
  PASS=$((PASS+1))
else
  print_fail "Task 4: desktop-svc 기본 규칙 미설정" \
    "matches 없이 backendRefs: desktop-svc 규칙 추가"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
