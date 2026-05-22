#!/bin/bash
# Problem 015: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q015"
PASS=0
TOTAL=0

check_cluster

# Task 1: ConfigMap apiserver-fixed-manifest 존재 여부
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get configmap apiserver-fixed-manifest &>/dev/null; then
  print_pass "Task 1: ConfigMap 'apiserver-fixed-manifest' 존재 확인"
  PASS=$((PASS+1))
else
  print_fail "Task 1: ConfigMap 'apiserver-fixed-manifest' 미존재" \
    "수정된 매니페스트를 ConfigMap으로 생성하세요"
fi

# Task 2: manifest에 올바른 etcd-servers 포함 확인
TOTAL=$((TOTAL+1))
MANIFEST=$(kubectl -n "$NAMESPACE" get configmap apiserver-fixed-manifest -o jsonpath='{.data.manifest}' 2>/dev/null)
if echo "$MANIFEST" | grep -q "etcd-servers=https://127.0.0.1:2379"; then
  print_pass "Task 2: manifest에 올바른 --etcd-servers=https://127.0.0.1:2379 포함"
  PASS=$((PASS+1))
else
  print_fail "Task 2: manifest에 올바른 etcd-servers 미포함" \
    "--etcd-servers=https://127.0.0.1:2379 로 수정하세요"
fi

# Task 3: 잘못된 포트가 제거되었는지 확인
TOTAL=$((TOTAL+1))
if echo "$MANIFEST" | grep -q "etcd-servers=https://127.0.0.1:1234"; then
  print_fail "Task 3: manifest에 여전히 잘못된 포트 1234 존재" \
    "포트를 2379로 수정하세요"
else
  print_pass "Task 3: 잘못된 etcd 포트 1234 제거됨"
  PASS=$((PASS+1))
fi

# Task 4: etcd-endpoint 키 확인
TOTAL=$((TOTAL+1))
ETCD_EP=$(kubectl -n "$NAMESPACE" get configmap apiserver-fixed-manifest -o jsonpath='{.data.etcd-endpoint}' 2>/dev/null)
if [ "$ETCD_EP" = "https://127.0.0.1:2379" ]; then
  print_pass "Task 4: etcd-endpoint 올바름 (https://127.0.0.1:2379)"
  PASS=$((PASS+1))
else
  print_fail "Task 4: etcd-endpoint 불일치 (현재: $ETCD_EP)" \
    "올바른 값: https://127.0.0.1:2379"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
