#!/bin/bash
# Problem 024: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q024"
PASS=0
TOTAL=0

check_cluster

# Task 1: ConfigMap 존재 여부
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get configmap cert-renewal-answer &>/dev/null; then
  print_pass "Task 1: ConfigMap 'cert-renewal-answer' 존재"
  PASS=$((PASS+1))
else
  print_fail "Task 1: ConfigMap 'cert-renewal-answer' 미생성" "kubectl create configmap cert-renewal-answer 명령을 사용하세요"
fi

# Task 2: expiry-date 값 확인
TOTAL=$((TOTAL+1))
EXPIRY=$(kubectl -n "$NAMESPACE" get configmap cert-renewal-answer -o jsonpath='{.data.expiry-date}' 2>/dev/null)
if echo "$EXPIRY" | grep -q "Jan 15" && echo "$EXPIRY" | grep -q "2025"; then
  print_pass "Task 2: 'expiry-date' 값 올바름 ($EXPIRY)"
  PASS=$((PASS+1))
else
  print_fail "Task 2: 'expiry-date' 값 불일치 (현재: $EXPIRY)" "인증서의 Not After 날짜를 확인하세요"
fi

# Task 3: renew-command 값 확인
TOTAL=$((TOTAL+1))
RENEW_CMD=$(kubectl -n "$NAMESPACE" get configmap cert-renewal-answer -o jsonpath='{.data.renew-command}' 2>/dev/null)
if echo "$RENEW_CMD" | grep -q "kubeadm" && echo "$RENEW_CMD" | grep -q "certs" && echo "$RENEW_CMD" | grep -q "renew"; then
  print_pass "Task 3: 'renew-command' 값 올바름 ($RENEW_CMD)"
  PASS=$((PASS+1))
else
  print_fail "Task 3: 'renew-command' 값 불일치 (현재: $RENEW_CMD)" "kubeadm certs renew 명령을 사용하세요"
fi

# Task 4: check-command 값 확인
TOTAL=$((TOTAL+1))
CHECK_CMD=$(kubectl -n "$NAMESPACE" get configmap cert-renewal-answer -o jsonpath='{.data.check-command}' 2>/dev/null)
if echo "$CHECK_CMD" | grep -q "kubeadm" && echo "$CHECK_CMD" | grep -q "check-expiration"; then
  print_pass "Task 4: 'check-command' 값 올바름 ($CHECK_CMD)"
  PASS=$((PASS+1))
else
  print_fail "Task 4: 'check-command' 값 불일치 (현재: $CHECK_CMD)" "kubeadm certs check-expiration 명령을 사용하세요"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
