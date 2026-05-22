#!/bin/bash
# Problem 100: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NS_FRONTEND="cka-q100-frontend"
NS_BACKEND="cka-q100-backend"
NS_DB="cka-q100-db"
PASS=0
TOTAL=0

check_cluster

# Task 1: allow-from-frontend NetworkPolicy 확인 (backend ns)
TOTAL=$((TOTAL+1))
if kubectl -n "$NS_BACKEND" get networkpolicy allow-from-frontend &>/dev/null; then
  TARGET=$(kubectl -n "$NS_BACKEND" get networkpolicy allow-from-frontend -o jsonpath='{.spec.podSelector.matchLabels.role}' 2>/dev/null)
  NS_SEL=$(kubectl -n "$NS_BACKEND" get networkpolicy allow-from-frontend -o jsonpath='{.spec.ingress[0].from[0].namespaceSelector.matchLabels}' 2>/dev/null)
  PORT=$(kubectl -n "$NS_BACKEND" get networkpolicy allow-from-frontend -o jsonpath='{.spec.ingress[0].ports[0].port}' 2>/dev/null)
  if [ "$TARGET" = "backend" ] && echo "$NS_SEL" | grep -q "cka-q100-frontend" && [ "$PORT" = "8080" ]; then
    print_pass "Task 1: allow-from-frontend 올바름 (backend←frontend-ns:8080)"
    PASS=$((PASS+1))
  else
    print_fail "Task 1: allow-from-frontend 스펙 불일치 (target=$TARGET, port=$PORT)" \
      "podSelector: role:backend, namespaceSelector: frontend-ns, port: 8080 확인"
  fi
else
  print_fail "Task 1: NetworkPolicy 'allow-from-frontend' 미생성 (backend ns)" \
    "cka-q100-backend 네임스페이스에 NetworkPolicy를 생성하세요"
fi

# Task 2: allow-from-backend NetworkPolicy 확인 (db ns)
TOTAL=$((TOTAL+1))
if kubectl -n "$NS_DB" get networkpolicy allow-from-backend &>/dev/null; then
  TARGET=$(kubectl -n "$NS_DB" get networkpolicy allow-from-backend -o jsonpath='{.spec.podSelector.matchLabels.role}' 2>/dev/null)
  NS_SEL=$(kubectl -n "$NS_DB" get networkpolicy allow-from-backend -o jsonpath='{.spec.ingress[0].from[0].namespaceSelector.matchLabels}' 2>/dev/null)
  PORT=$(kubectl -n "$NS_DB" get networkpolicy allow-from-backend -o jsonpath='{.spec.ingress[0].ports[0].port}' 2>/dev/null)
  if [ "$TARGET" = "db" ] && echo "$NS_SEL" | grep -q "cka-q100-backend" && [ "$PORT" = "5432" ]; then
    print_pass "Task 2: allow-from-backend 올바름 (db←backend-ns:5432)"
    PASS=$((PASS+1))
  else
    print_fail "Task 2: allow-from-backend 스펙 불일치 (target=$TARGET, port=$PORT)" \
      "podSelector: role:db, namespaceSelector: backend-ns, port: 5432 확인"
  fi
else
  print_fail "Task 2: NetworkPolicy 'allow-from-backend' 미생성 (db ns)" \
    "cka-q100-db 네임스페이스에 NetworkPolicy를 생성하세요"
fi

# Task 3: default-deny-ingress NetworkPolicy 확인 (db ns)
TOTAL=$((TOTAL+1))
if kubectl -n "$NS_DB" get networkpolicy default-deny-ingress &>/dev/null; then
  POD_SEL=$(kubectl -n "$NS_DB" get networkpolicy default-deny-ingress -o jsonpath='{.spec.podSelector}' 2>/dev/null)
  POLICY_TYPES=$(kubectl -n "$NS_DB" get networkpolicy default-deny-ingress -o jsonpath='{.spec.policyTypes}' 2>/dev/null)
  if ([ "$POD_SEL" = "{}" ] || [ -z "$POD_SEL" ]) && echo "$POLICY_TYPES" | grep -q "Ingress"; then
    print_pass "Task 3: default-deny-ingress 올바름 (빈 podSelector, Ingress 차단)"
    PASS=$((PASS+1))
  else
    print_fail "Task 3: default-deny-ingress 스펙 불일치 (podSelector=$POD_SEL, types=$POLICY_TYPES)" \
      "빈 podSelector, policyTypes: [Ingress] 확인"
  fi
else
  print_fail "Task 3: NetworkPolicy 'default-deny-ingress' 미생성 (db ns)" \
    "cka-q100-db 네임스페이스에 기본 거부 정책을 생성하세요"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
