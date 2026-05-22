#!/bin/bash
# Problem 056: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q056"
PASS=0
TOTAL=0

check_cluster

# Task 1: ConfigMap context-info의 contexts 키 확인
TOTAL=$((TOTAL+1))
CONTEXTS=$(kubectl -n "$NAMESPACE" get configmap context-info -o jsonpath='{.data.contexts}' 2>/dev/null)
if [ "$CONTEXTS" = "dev-context,prod-context,staging-context" ]; then
  print_pass "Task 1: contexts 키에 올바른 context 목록 저장됨"
  PASS=$((PASS+1))
else
  print_fail "Task 1: contexts 키 값 불일치 (현재: '$CONTEXTS')" \
    "알파벳 순서로 정렬하여 쉼표로 구분: dev-context,prod-context,staging-context"
fi

# Task 2: current-context 키 확인
TOTAL=$((TOTAL+1))
CURRENT=$(kubectl -n "$NAMESPACE" get configmap context-info -o jsonpath='{.data.current-context}' 2>/dev/null)
if [ "$CURRENT" = "dev-context" ]; then
  print_pass "Task 2: current-context 키에 올바른 값 저장됨"
  PASS=$((PASS+1))
else
  print_fail "Task 2: current-context 키 값 불일치 (현재: '$CURRENT')" \
    "kubeconfig의 current-context 필드를 확인하세요"
fi

# Task 3: cert-subject 키 확인
TOTAL=$((TOTAL+1))
CERT_SUBJECT=$(kubectl -n "$NAMESPACE" get configmap context-info -o jsonpath='{.data.cert-subject}' 2>/dev/null)
if echo "$CERT_SUBJECT" | grep -q "CN=dev-user"; then
  print_pass "Task 3: cert-subject 키에 CN=dev-user 포함됨"
  PASS=$((PASS+1))
else
  print_fail "Task 3: cert-subject 키에 CN=dev-user 미포함 (현재: '$CERT_SUBJECT')" \
    "client-certificate-data를 base64 디코딩 후 openssl x509 -subject로 확인"
fi

# Task 4: cluster-count 키 확인
TOTAL=$((TOTAL+1))
CLUSTER_COUNT=$(kubectl -n "$NAMESPACE" get configmap context-info -o jsonpath='{.data.cluster-count}' 2>/dev/null)
if [ "$CLUSTER_COUNT" = "3" ]; then
  print_pass "Task 4: cluster-count 키에 올바른 값 저장됨"
  PASS=$((PASS+1))
else
  print_fail "Task 4: cluster-count 키 값 불일치 (현재: '$CLUSTER_COUNT')" \
    "kubeconfig에 정의된 클러스터 수를 확인하세요"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
