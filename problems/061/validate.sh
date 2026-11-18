#!/bin/bash
# Problem 061: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q061"
PASS=0
TOTAL=0

check_cluster

# Task 1: ConfigMap upgrade-procedure 존재
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get configmap upgrade-procedure &>/dev/null; then
  print_pass "Task 1: ConfigMap 'upgrade-procedure' 존재"
  PASS=$((PASS+1))
else
  print_fail "Task 1: ConfigMap 'upgrade-procedure' 미생성" \
    "kubectl -n cka-q061 create configmap upgrade-procedure 명령을 사용하세요"
fi

# Task 2: step1에 drain 명령 포함
TOTAL=$((TOTAL+1))
STEP1=$(kubectl -n "$NAMESPACE" get configmap upgrade-procedure -o jsonpath='{.data.step1}' 2>/dev/null)
NODE_NAME=$(kubectl -n "$NAMESPACE" get configmap cluster-info -o jsonpath='{.data.node-name}' 2>/dev/null)
NODE_NAME=${NODE_NAME:-docker-desktop}
if echo "$STEP1" | grep -q "drain" && echo "$STEP1" | grep -q "$NODE_NAME"; then
  print_pass "Task 2: step1에 drain 명령 포함"
  PASS=$((PASS+1))
else
  print_fail "Task 2: step1에 drain 명령 미포함 (현재: '$STEP1')" \
    "kubectl drain $NODE_NAME --ignore-daemonsets 형태의 명령을 작성하세요"
fi

# Task 3: step2에 kubeadm upgrade 명령 포함
TOTAL=$((TOTAL+1))
STEP2=$(kubectl -n "$NAMESPACE" get configmap upgrade-procedure -o jsonpath='{.data.step2}' 2>/dev/null)
if echo "$STEP2" | grep -q "kubeadm upgrade" && echo "$STEP2" | grep -q "v1.29.0"; then
  print_pass "Task 3: step2에 kubeadm upgrade 명령 포함"
  PASS=$((PASS+1))
else
  print_fail "Task 3: step2에 kubeadm upgrade 명령 미포함 (현재: '$STEP2')" \
    "kubeadm upgrade plan && kubeadm upgrade apply v1.29.0"
fi

# Task 4: step3에 uncordon 명령 포함
TOTAL=$((TOTAL+1))
STEP3=$(kubectl -n "$NAMESPACE" get configmap upgrade-procedure -o jsonpath='{.data.step3}' 2>/dev/null)
if echo "$STEP3" | grep -q "uncordon"; then
  print_pass "Task 4: step3에 uncordon 명령 포함"
  PASS=$((PASS+1))
else
  print_fail "Task 4: step3에 uncordon 명령 미포함 (현재: '$STEP3')" \
    "kubectl uncordon $NODE_NAME"
fi

# Task 5: upgrade-order 확인
TOTAL=$((TOTAL+1))
UPGRADE_ORDER=$(kubectl -n "$NAMESPACE" get configmap upgrade-procedure -o jsonpath='{.data.upgrade-order}' 2>/dev/null)
if [ "$UPGRADE_ORDER" = "drain,upgrade-kubeadm,upgrade-apply,upgrade-kubelet,restart-kubelet,uncordon" ]; then
  print_pass "Task 5: upgrade-order 올바르게 작성됨"
  PASS=$((PASS+1))
else
  print_fail "Task 5: upgrade-order 불일치 (현재: '$UPGRADE_ORDER')" \
    "drain,upgrade-kubeadm,upgrade-apply,upgrade-kubelet,restart-kubelet,uncordon"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
