#!/bin/bash
# Problem 094: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q094"
PASS=0
TOTAL=0

check_cluster

# Task 1: Service 'legacy-svc'에 selector 없음 확인
TOTAL=$((TOTAL+1))
SELECTOR=$(kubectl -n "$NAMESPACE" get svc legacy-svc -o jsonpath='{.spec.selector}' 2>/dev/null)
if [ -z "$SELECTOR" ] || [ "$SELECTOR" = "{}" ] || [ "$SELECTOR" = "null" ]; then
  print_pass "Task 1: Service 'legacy-svc' selector 없음 확인"
  PASS=$((PASS+1))
else
  print_fail "Task 1: Service 'legacy-svc'에 selector 존재 ($SELECTOR)" \
    "selector가 없는 Service여야 합니다"
fi

# Task 2: Endpoints 'legacy-svc' 존재 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get endpoints legacy-svc &>/dev/null; then
  print_pass "Task 2: Endpoints 'legacy-svc' 존재"
  PASS=$((PASS+1))
else
  print_fail "Task 2: Endpoints 'legacy-svc' 미생성" \
    "Service와 같은 이름의 Endpoints를 생성하세요"
fi

# Task 3: Endpoints IP 확인
TOTAL=$((TOTAL+1))
EP_IP=$(kubectl -n "$NAMESPACE" get endpoints legacy-svc -o jsonpath='{.subsets[0].addresses[0].ip}' 2>/dev/null)
if [ "$EP_IP" = "10.0.0.100" ]; then
  print_pass "Task 3: Endpoints IP=10.0.0.100 올바름"
  PASS=$((PASS+1))
else
  print_fail "Task 3: Endpoints IP 불일치 (현재: $EP_IP)" \
    "subsets[].addresses[].ip: 10.0.0.100 확인"
fi

# Task 4: Endpoints port 확인
TOTAL=$((TOTAL+1))
EP_PORT=$(kubectl -n "$NAMESPACE" get endpoints legacy-svc -o jsonpath='{.subsets[0].ports[0].port}' 2>/dev/null)
if [ "$EP_PORT" = "8080" ]; then
  print_pass "Task 4: Endpoints port=8080 올바름"
  PASS=$((PASS+1))
else
  print_fail "Task 4: Endpoints port 불일치 (현재: $EP_PORT)" \
    "subsets[].ports[].port: 8080 확인"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
