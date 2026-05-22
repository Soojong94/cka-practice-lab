#!/bin/bash
# Problem 087: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q087"
PASS=0
TOTAL=0

check_cluster

# Task 1: default-deny-all NetworkPolicy 존재 및 빈 podSelector 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get networkpolicy default-deny-all &>/dev/null; then
  POD_SEL=$(kubectl -n "$NAMESPACE" get networkpolicy default-deny-all -o jsonpath='{.spec.podSelector}' 2>/dev/null)
  POLICY_TYPES=$(kubectl -n "$NAMESPACE" get networkpolicy default-deny-all -o jsonpath='{.spec.policyTypes}' 2>/dev/null)
  if ([ "$POD_SEL" = "{}" ] || [ "$POD_SEL" = "" ]) && echo "$POLICY_TYPES" | grep -q "Ingress" && echo "$POLICY_TYPES" | grep -q "Egress"; then
    print_pass "Task 1: default-deny-all 정책 올바름 (빈 podSelector, Ingress+Egress)"
    PASS=$((PASS+1))
  else
    print_fail "Task 1: default-deny-all 스펙 불일치 (podSelector=$POD_SEL, types=$POLICY_TYPES)" \
      "빈 podSelector와 policyTypes [Ingress, Egress] 확인"
  fi
else
  print_fail "Task 1: NetworkPolicy 'default-deny-all' 미생성" \
    "기본 거부 정책을 생성하세요"
fi

# Task 2: allow-web-to-api NetworkPolicy 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get networkpolicy allow-web-to-api &>/dev/null; then
  TARGET=$(kubectl -n "$NAMESPACE" get networkpolicy allow-web-to-api -o jsonpath='{.spec.podSelector.matchLabels.role}' 2>/dev/null)
  FROM=$(kubectl -n "$NAMESPACE" get networkpolicy allow-web-to-api -o jsonpath='{.spec.ingress[0].from[0].podSelector.matchLabels.role}' 2>/dev/null)
  PORT=$(kubectl -n "$NAMESPACE" get networkpolicy allow-web-to-api -o jsonpath='{.spec.ingress[0].ports[0].port}' 2>/dev/null)
  if [ "$TARGET" = "api" ] && [ "$FROM" = "web" ] && [ "$PORT" = "8080" ]; then
    print_pass "Task 2: allow-web-to-api 정책 올바름 (api←web:8080)"
    PASS=$((PASS+1))
  else
    print_fail "Task 2: allow-web-to-api 스펙 불일치 (target=$TARGET, from=$FROM, port=$PORT)" \
      "podSelector: role:api, from: role:web, port: 8080 확인"
  fi
else
  print_fail "Task 2: NetworkPolicy 'allow-web-to-api' 미생성" \
    "web→api 허용 정책을 생성하세요"
fi

# Task 3: allow-api-to-db NetworkPolicy 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get networkpolicy allow-api-to-db &>/dev/null; then
  TARGET=$(kubectl -n "$NAMESPACE" get networkpolicy allow-api-to-db -o jsonpath='{.spec.podSelector.matchLabels.role}' 2>/dev/null)
  FROM=$(kubectl -n "$NAMESPACE" get networkpolicy allow-api-to-db -o jsonpath='{.spec.ingress[0].from[0].podSelector.matchLabels.role}' 2>/dev/null)
  PORT=$(kubectl -n "$NAMESPACE" get networkpolicy allow-api-to-db -o jsonpath='{.spec.ingress[0].ports[0].port}' 2>/dev/null)
  if [ "$TARGET" = "db" ] && [ "$FROM" = "api" ] && [ "$PORT" = "5432" ]; then
    print_pass "Task 3: allow-api-to-db 정책 올바름 (db←api:5432)"
    PASS=$((PASS+1))
  else
    print_fail "Task 3: allow-api-to-db 스펙 불일치 (target=$TARGET, from=$FROM, port=$PORT)" \
      "podSelector: role:db, from: role:api, port: 5432 확인"
  fi
else
  print_fail "Task 3: NetworkPolicy 'allow-api-to-db' 미생성" \
    "api→db 허용 정책을 생성하세요"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
