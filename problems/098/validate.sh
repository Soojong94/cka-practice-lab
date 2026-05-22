#!/bin/bash
# Problem 098: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q098"
PASS=0
TOTAL=0

check_cluster

# Task 1: Service 'web-internal' 존재 및 internalTrafficPolicy 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get svc web-internal &>/dev/null; then
  ITP=$(kubectl -n "$NAMESPACE" get svc web-internal -o jsonpath='{.spec.internalTrafficPolicy}' 2>/dev/null)
  if [ "$ITP" = "Local" ]; then
    print_pass "Task 1: Service 'web-internal' internalTrafficPolicy=Local 올바름"
    PASS=$((PASS+1))
  else
    print_fail "Task 1: internalTrafficPolicy 불일치 (현재: $ITP)" \
      "spec.internalTrafficPolicy: Local 확인"
  fi
else
  print_fail "Task 1: Service 'web-internal' 미생성" \
    "ClusterIP Service를 생성하세요"
fi

# Task 2: Service 'web-external' 존재 및 externalTrafficPolicy 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get svc web-external &>/dev/null; then
  ETP=$(kubectl -n "$NAMESPACE" get svc web-external -o jsonpath='{.spec.externalTrafficPolicy}' 2>/dev/null)
  if [ "$ETP" = "Local" ]; then
    print_pass "Task 2: Service 'web-external' externalTrafficPolicy=Local 올바름"
    PASS=$((PASS+1))
  else
    print_fail "Task 2: externalTrafficPolicy 불일치 (현재: $ETP)" \
      "spec.externalTrafficPolicy: Local 확인"
  fi
else
  print_fail "Task 2: Service 'web-external' 미생성" \
    "NodePort Service를 생성하세요"
fi

# Task 3: web-external 타입 NodePort 확인
TOTAL=$((TOTAL+1))
SVC_TYPE=$(kubectl -n "$NAMESPACE" get svc web-external -o jsonpath='{.spec.type}' 2>/dev/null)
if [ "$SVC_TYPE" = "NodePort" ]; then
  print_pass "Task 3: Service 'web-external' 타입=NodePort 올바름"
  PASS=$((PASS+1))
else
  print_fail "Task 3: Service 타입 불일치 (현재: $SVC_TYPE)" \
    "externalTrafficPolicy는 NodePort/LoadBalancer에서만 사용 가능"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
