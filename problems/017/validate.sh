#!/bin/bash
# Problem 017: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q017"
PASS=0
TOTAL=0

check_cluster

# Task 1: ConfigMap controller-manager-fixed-manifest 존재 여부
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get configmap controller-manager-fixed-manifest &>/dev/null; then
  print_pass "Task 1: ConfigMap 'controller-manager-fixed-manifest' 존재 확인"
  PASS=$((PASS+1))
else
  print_fail "Task 1: ConfigMap 'controller-manager-fixed-manifest' 미존재" \
    "수정된 매니페스트를 ConfigMap으로 생성하세요"
fi

# Task 2: manifest에 올바른 cluster-signing-cert-file 포함 확인
TOTAL=$((TOTAL+1))
MANIFEST=$(kubectl -n "$NAMESPACE" get configmap controller-manager-fixed-manifest -o jsonpath='{.data.manifest}' 2>/dev/null)
if echo "$MANIFEST" | grep -q "\-\-cluster-signing-cert-file=/etc/kubernetes/pki/ca.crt"; then
  print_pass "Task 2: --cluster-signing-cert-file=/etc/kubernetes/pki/ca.crt 올바름"
  PASS=$((PASS+1))
else
  print_fail "Task 2: --cluster-signing-cert-file 경로 불일치" \
    "--cluster-signing-cert-file=/etc/kubernetes/pki/ca.crt 로 수정하세요"
fi

# Task 3: manifest에 올바른 cluster-signing-key-file 포함 확인
TOTAL=$((TOTAL+1))
if echo "$MANIFEST" | grep -q "\-\-cluster-signing-key-file=/etc/kubernetes/pki/ca.key"; then
  print_pass "Task 3: --cluster-signing-key-file=/etc/kubernetes/pki/ca.key 올바름"
  PASS=$((PASS+1))
else
  print_fail "Task 3: --cluster-signing-key-file 경로 불일치" \
    "--cluster-signing-key-file=/etc/kubernetes/pki/ca.key 로 수정하세요"
fi

# Task 4: 잘못된 경로가 제거되었는지 확인
TOTAL=$((TOTAL+1))
if echo "$MANIFEST" | grep -q "wrong-ca"; then
  print_fail "Task 4: manifest에 여전히 'wrong-ca' 경로 존재" \
    "wrong-ca.crt → ca.crt, wrong-ca.key → ca.key 로 수정하세요"
else
  print_pass "Task 4: 잘못된 'wrong-ca' 경로 제거됨"
  PASS=$((PASS+1))
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
