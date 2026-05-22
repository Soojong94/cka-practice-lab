#!/bin/bash
# Problem 078: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q078"
PASS=0
TOTAL=0

check_cluster

# ConfigMap에서 값 추출
CA_CERT=$(kubectl -n "$NAMESPACE" get configmap cert-chain-info -o jsonpath='{.data.ca-cert}' 2>/dev/null)
APISERVER_CERT=$(kubectl -n "$NAMESPACE" get configmap cert-chain-info -o jsonpath='{.data.apiserver-cert}' 2>/dev/null)
KUBELET_CLIENT=$(kubectl -n "$NAMESPACE" get configmap cert-chain-info -o jsonpath='{.data.apiserver-kubelet-client}' 2>/dev/null)

# Task 1: ca-cert에 올바른 경로와 정보가 있는지
TOTAL=$((TOTAL+1))
if echo "$CA_CERT" | grep -q '/etc/kubernetes/pki/ca.crt' && echo "$CA_CERT" | grep -qi 'kubernetes'; then
  print_pass "Task 1: CA 인증서 정보 올바르게 기록됨"
  PASS=$((PASS+1))
else
  print_fail "Task 1: CA 인증서 정보 불완전" "경로: /etc/kubernetes/pki/ca.crt, issuer/subject: kubernetes"
fi

# Task 2: ca-cert에 issuer와 subject가 있는지
TOTAL=$((TOTAL+1))
if echo "$CA_CERT" | grep -qi 'issuer' && echo "$CA_CERT" | grep -qi 'subject'; then
  print_pass "Task 2: CA 인증서에 issuer/subject 정보 포함"
  PASS=$((PASS+1))
else
  print_fail "Task 2: CA 인증서에 issuer/subject 정보 누락" "issuer와 subject를 기록하세요"
fi

# Task 3: apiserver-cert에 올바른 경로와 정보가 있는지
TOTAL=$((TOTAL+1))
if echo "$APISERVER_CERT" | grep -q '/etc/kubernetes/pki/apiserver.crt' && echo "$APISERVER_CERT" | grep -qi 'kube-apiserver'; then
  print_pass "Task 3: API 서버 인증서 정보 올바르게 기록됨"
  PASS=$((PASS+1))
else
  print_fail "Task 3: API 서버 인증서 정보 불완전" "경로: /etc/kubernetes/pki/apiserver.crt, subject: kube-apiserver"
fi

# Task 4: apiserver-kubelet-client에 올바른 경로와 정보가 있는지
TOTAL=$((TOTAL+1))
if echo "$KUBELET_CLIENT" | grep -q '/etc/kubernetes/pki/apiserver-kubelet-client.crt' && echo "$KUBELET_CLIENT" | grep -qi 'kubelet'; then
  print_pass "Task 4: kubelet 클라이언트 인증서 정보 올바르게 기록됨"
  PASS=$((PASS+1))
else
  print_fail "Task 4: kubelet 클라이언트 인증서 정보 불완전" "경로: /etc/kubernetes/pki/apiserver-kubelet-client.crt"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
