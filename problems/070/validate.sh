#!/bin/bash
# Problem 070: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q070"
PASS=0
TOTAL=0

check_cluster

# 실제 인증서 정보 추출 (검증 기준)
CERT_DATA=$(kubectl --kubeconfig=/tmp/cka-q070/kubeconfig config view --raw \
  -o jsonpath='{.users[?(@.name=="admin-user")].user.client-certificate-data}' 2>/dev/null)

# Task 1: issuer 확인
TOTAL=$((TOTAL+1))
ISSUER=$(kubectl -n "$NAMESPACE" get configmap cert-info -o jsonpath='{.data.issuer}' 2>/dev/null)
if echo "$ISSUER" | grep -q "CN.*=.*kubernetes-ca"; then
  print_pass "Task 1: issuer에 CN=kubernetes-ca 포함"
  PASS=$((PASS+1))
else
  print_fail "Task 1: issuer에 CN=kubernetes-ca 미포함 (현재: '$ISSUER')" \
    "openssl x509 -noout -issuer 로 확인하세요"
fi

# Task 2: expiry 확인
TOTAL=$((TOTAL+1))
EXPIRY=$(kubectl -n "$NAMESPACE" get configmap cert-info -o jsonpath='{.data.expiry}' 2>/dev/null)
if [ -n "$EXPIRY" ] && echo "$EXPIRY" | grep -qE "[0-9]{4}|[A-Z][a-z]{2}"; then
  print_pass "Task 2: expiry에 날짜 정보 포함"
  PASS=$((PASS+1))
else
  print_fail "Task 2: expiry 값이 비어있거나 날짜 형식 아님 (현재: '$EXPIRY')" \
    "openssl x509 -noout -enddate 로 확인하세요"
fi

# Task 3: subject 확인
TOTAL=$((TOTAL+1))
SUBJECT=$(kubectl -n "$NAMESPACE" get configmap cert-info -o jsonpath='{.data.subject}' 2>/dev/null)
if echo "$SUBJECT" | grep -q "CN.*=.*admin-user"; then
  print_pass "Task 3: subject에 CN=admin-user 포함"
  PASS=$((PASS+1))
else
  print_fail "Task 3: subject에 CN=admin-user 미포함 (현재: '$SUBJECT')" \
    "openssl x509 -noout -subject 로 확인하세요"
fi

# Task 4: is-valid 확인
TOTAL=$((TOTAL+1))
IS_VALID=$(kubectl -n "$NAMESPACE" get configmap cert-info -o jsonpath='{.data.is-valid}' 2>/dev/null)
if [ "$IS_VALID" = "true" ]; then
  print_pass "Task 4: is-valid = true"
  PASS=$((PASS+1))
else
  print_fail "Task 4: is-valid 불일치 (현재: '$IS_VALID')" \
    "openssl x509 -checkend 0 으로 유효성을 확인하세요"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
