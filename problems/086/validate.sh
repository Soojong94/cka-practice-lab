#!/bin/bash
# Problem 086: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q086"
PASS=0
TOTAL=0

check_cluster

# Task 1: NetworkPolicy 'app-egress' 존재 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get networkpolicy app-egress &>/dev/null; then
  print_pass "Task 1: NetworkPolicy 'app-egress' 존재"
  PASS=$((PASS+1))
else
  print_fail "Task 1: NetworkPolicy 'app-egress' 미생성" \
    "NetworkPolicy 리소스를 생성하세요"
fi

# Task 2: podSelector 확인 (role: app)
TOTAL=$((TOTAL+1))
POD_SELECTOR=$(kubectl -n "$NAMESPACE" get networkpolicy app-egress -o jsonpath='{.spec.podSelector.matchLabels.role}' 2>/dev/null)
if [ "$POD_SELECTOR" = "app" ]; then
  print_pass "Task 2: podSelector=role:app 올바름"
  PASS=$((PASS+1))
else
  print_fail "Task 2: podSelector 불일치 (현재: role=$POD_SELECTOR)" \
    "spec.podSelector.matchLabels.role: app 확인"
fi

# Task 3: policyTypes에 Egress 포함 확인
TOTAL=$((TOTAL+1))
POLICY_TYPES=$(kubectl -n "$NAMESPACE" get networkpolicy app-egress -o jsonpath='{.spec.policyTypes}' 2>/dev/null)
if echo "$POLICY_TYPES" | grep -q "Egress"; then
  print_pass "Task 3: policyTypes에 Egress 포함"
  PASS=$((PASS+1))
else
  print_fail "Task 3: policyTypes에 Egress 미포함 (현재: $POLICY_TYPES)" \
    "spec.policyTypes: [Egress] 확인"
fi

# Task 4: Egress 규칙에 port 5432 포함 확인
TOTAL=$((TOTAL+1))
EGRESS_JSON=$(kubectl -n "$NAMESPACE" get networkpolicy app-egress -o json 2>/dev/null)
HAS_5432=$(echo "$EGRESS_JSON" | grep -o '"port":5432' | head -1)
HAS_53=$(echo "$EGRESS_JSON" | grep -o '"port":53' | head -1)
if [ -n "$HAS_5432" ] && [ -n "$HAS_53" ]; then
  print_pass "Task 4: Egress 규칙에 port 5432(db)와 port 53(DNS) 포함"
  PASS=$((PASS+1))
else
  print_fail "Task 4: Egress 규칙 불완전 (5432=${HAS_5432:-없음}, 53=${HAS_53:-없음})" \
    "db Pod port 5432와 DNS port 53 규칙을 모두 포함하세요"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
