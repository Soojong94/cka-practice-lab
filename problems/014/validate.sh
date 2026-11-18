#!/bin/bash
# Problem 014: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q014"
PASS=0
TOTAL=0

check_cluster

# Task 1: ConfigMap kubelet-answer 존재 여부
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get configmap kubelet-answer &>/dev/null; then
  print_pass "Task 1: ConfigMap 'kubelet-answer' 존재 확인"
  PASS=$((PASS+1))
else
  print_fail "Task 1: ConfigMap 'kubelet-answer' 미존재" \
    "kubectl -n $NAMESPACE create configmap kubelet-answer --from-literal=... 로 생성하세요"
fi

# Task 2: restart-command 확인
TOTAL=$((TOTAL+1))
RESTART_CMD=$(kubectl -n "$NAMESPACE" get configmap kubelet-answer -o jsonpath='{.data.restart-command}' 2>/dev/null)
if [ "$RESTART_CMD" = "systemctl restart kubelet" ]; then
  print_pass "Task 2: restart-command 올바름"
  PASS=$((PASS+1))
else
  print_fail "Task 2: restart-command 불일치 (현재: $RESTART_CMD)" \
    "올바른 값: systemctl restart kubelet"
fi

# Task 3: enable-command 확인
TOTAL=$((TOTAL+1))
ENABLE_CMD=$(kubectl -n "$NAMESPACE" get configmap kubelet-answer -o jsonpath='{.data.enable-command}' 2>/dev/null)
if [ "$ENABLE_CMD" = "systemctl enable kubelet" ]; then
  print_pass "Task 3: enable-command 올바름"
  PASS=$((PASS+1))
else
  print_fail "Task 3: enable-command 불일치 (현재: $ENABLE_CMD)" \
    "올바른 값: systemctl enable kubelet"
fi

# Task 4: check-command 확인
TOTAL=$((TOTAL+1))
CHECK_CMD=$(kubectl -n "$NAMESPACE" get configmap kubelet-answer -o jsonpath='{.data.check-command}' 2>/dev/null)
if [ "$CHECK_CMD" = "systemctl status kubelet" ]; then
  print_pass "Task 4: check-command 올바름"
  PASS=$((PASS+1))
else
  print_fail "Task 4: check-command 불일치 (현재: $CHECK_CMD)" \
    "올바른 값: systemctl status kubelet"
fi

# Task 5: config-path 확인
TOTAL=$((TOTAL+1))
CONFIG_PATH=$(kubectl -n "$NAMESPACE" get configmap kubelet-answer -o jsonpath='{.data.config-path}' 2>/dev/null)
CONFIG_PATH=$(unmangle_path "$CONFIG_PATH")
if [ "$CONFIG_PATH" = "/var/lib/kubelet/config.yaml" ]; then
  print_pass "Task 5: config-path 올바름"
  PASS=$((PASS+1))
else
  print_fail "Task 5: config-path 불일치 (현재: $CONFIG_PATH)" \
    "올바른 값: /var/lib/kubelet/config.yaml"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
