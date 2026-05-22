#!/bin/bash
# Problem 016: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q016"
PASS=0
TOTAL=0

check_cluster

# Task 1: ConfigMap scheduler-fixed-manifest 존재 여부
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get configmap scheduler-fixed-manifest &>/dev/null; then
  print_pass "Task 1: ConfigMap 'scheduler-fixed-manifest' 존재 확인"
  PASS=$((PASS+1))
else
  print_fail "Task 1: ConfigMap 'scheduler-fixed-manifest' 미존재" \
    "수정된 매니페스트를 ConfigMap으로 생성하세요"
fi

# Task 2: manifest에 올바른 kubeconfig 경로 포함 확인
TOTAL=$((TOTAL+1))
MANIFEST=$(kubectl -n "$NAMESPACE" get configmap scheduler-fixed-manifest -o jsonpath='{.data.manifest}' 2>/dev/null)
if echo "$MANIFEST" | grep -q "\-\-kubeconfig=/etc/kubernetes/scheduler.conf"; then
  print_pass "Task 2: manifest에 올바른 --kubeconfig=/etc/kubernetes/scheduler.conf 포함"
  PASS=$((PASS+1))
else
  print_fail "Task 2: manifest에 올바른 kubeconfig 경로 미포함" \
    "--kubeconfig=/etc/kubernetes/scheduler.conf 로 수정하세요"
fi

# Task 3: authentication-kubeconfig 경로 확인
TOTAL=$((TOTAL+1))
if echo "$MANIFEST" | grep -q "\-\-authentication-kubeconfig=/etc/kubernetes/scheduler.conf"; then
  print_pass "Task 3: --authentication-kubeconfig 경로 올바름"
  PASS=$((PASS+1))
else
  print_fail "Task 3: --authentication-kubeconfig 경로 불일치" \
    "--authentication-kubeconfig=/etc/kubernetes/scheduler.conf 로 수정하세요"
fi

# Task 4: authorization-kubeconfig 경로 확인
TOTAL=$((TOTAL+1))
if echo "$MANIFEST" | grep -q "\-\-authorization-kubeconfig=/etc/kubernetes/scheduler.conf"; then
  print_pass "Task 4: --authorization-kubeconfig 경로 올바름"
  PASS=$((PASS+1))
else
  print_fail "Task 4: --authorization-kubeconfig 경로 불일치" \
    "--authorization-kubeconfig=/etc/kubernetes/scheduler.conf 로 수정하세요"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
