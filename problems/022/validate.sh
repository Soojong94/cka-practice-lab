#!/bin/bash
# Problem 022: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q022"
PASS=0
TOTAL=0

check_cluster

# Task 1: ConfigMap 존재 여부
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get configmap node-fix-answer &>/dev/null; then
  print_pass "Task 1: ConfigMap 'node-fix-answer' 존재"
  PASS=$((PASS+1))
else
  print_fail "Task 1: ConfigMap 'node-fix-answer' 미생성" "kubectl create configmap node-fix-answer 명령을 사용하세요"
fi

# Task 2: root-cause 값 확인
TOTAL=$((TOTAL+1))
ROOT_CAUSE=$(kubectl -n "$NAMESPACE" get configmap node-fix-answer -o jsonpath='{.data.root-cause}' 2>/dev/null)
if echo "$ROOT_CAUSE" | grep -qi "certificate" || echo "$ROOT_CAUSE" | grep -qi "expired"; then
  print_pass "Task 2: 'root-cause' 값에 올바른 키워드 포함 ($ROOT_CAUSE)"
  PASS=$((PASS+1))
else
  print_fail "Task 2: 'root-cause' 값 불일치 (현재: $ROOT_CAUSE)" "kubelet 로그에서 에러 원인을 확인하세요"
fi

# Task 3: fix-command 값 확인
TOTAL=$((TOTAL+1))
FIX_CMD=$(kubectl -n "$NAMESPACE" get configmap node-fix-answer -o jsonpath='{.data.fix-command}' 2>/dev/null)
if echo "$FIX_CMD" | grep -q "kubeadm" && echo "$FIX_CMD" | grep -q "renew"; then
  print_pass "Task 3: 'fix-command' 값 올바름 ($FIX_CMD)"
  PASS=$((PASS+1))
else
  print_fail "Task 3: 'fix-command' 값 불일치 (현재: $FIX_CMD)" "kubeadm certs renew 명령을 사용하세요"
fi

# Task 4: restart-command 값 확인
TOTAL=$((TOTAL+1))
RESTART_CMD=$(kubectl -n "$NAMESPACE" get configmap node-fix-answer -o jsonpath='{.data.restart-command}' 2>/dev/null)
if echo "$RESTART_CMD" | grep -q "systemctl" && echo "$RESTART_CMD" | grep -q "kubelet"; then
  print_pass "Task 4: 'restart-command' 값 올바름 ($RESTART_CMD)"
  PASS=$((PASS+1))
else
  print_fail "Task 4: 'restart-command' 값 불일치 (현재: $RESTART_CMD)" "systemctl restart kubelet 명령을 사용하세요"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
