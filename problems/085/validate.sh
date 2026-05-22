#!/bin/bash
# Problem 085: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q085"
PASS=0
TOTAL=0

check_cluster

# Task 1: NetworkPolicy 'allow-frontend' 존재 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get networkpolicy allow-frontend &>/dev/null; then
  print_pass "Task 1: NetworkPolicy 'allow-frontend' 존재"
  PASS=$((PASS+1))
else
  print_fail "Task 1: NetworkPolicy 'allow-frontend' 미생성" \
    "NetworkPolicy 리소스를 생성하세요"
fi

# Task 2: podSelector 확인 (role: backend)
TOTAL=$((TOTAL+1))
POD_SELECTOR=$(kubectl -n "$NAMESPACE" get networkpolicy allow-frontend -o jsonpath='{.spec.podSelector.matchLabels.role}' 2>/dev/null)
if [ "$POD_SELECTOR" = "backend" ]; then
  print_pass "Task 2: podSelector=role:backend 올바름"
  PASS=$((PASS+1))
else
  print_fail "Task 2: podSelector 불일치 (현재: role=$POD_SELECTOR)" \
    "spec.podSelector.matchLabels.role: backend 확인"
fi

# Task 3: Ingress from podSelector 확인 (role: frontend)
TOTAL=$((TOTAL+1))
FROM_SELECTOR=$(kubectl -n "$NAMESPACE" get networkpolicy allow-frontend -o jsonpath='{.spec.ingress[0].from[0].podSelector.matchLabels.role}' 2>/dev/null)
if [ "$FROM_SELECTOR" = "frontend" ]; then
  print_pass "Task 3: ingress from podSelector=role:frontend 올바름"
  PASS=$((PASS+1))
else
  print_fail "Task 3: ingress from podSelector 불일치 (현재: role=$FROM_SELECTOR)" \
    "spec.ingress[].from[].podSelector.matchLabels.role: frontend 확인"
fi

# Task 4: Ingress port 80 확인
TOTAL=$((TOTAL+1))
INGRESS_PORT=$(kubectl -n "$NAMESPACE" get networkpolicy allow-frontend -o jsonpath='{.spec.ingress[0].ports[0].port}' 2>/dev/null)
if [ "$INGRESS_PORT" = "80" ]; then
  print_pass "Task 4: ingress port=80 올바름"
  PASS=$((PASS+1))
else
  print_fail "Task 4: ingress port 불일치 (현재: $INGRESS_PORT)" \
    "spec.ingress[].ports[].port: 80 확인"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
