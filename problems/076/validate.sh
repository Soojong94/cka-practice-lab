#!/bin/bash
# Problem 076: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q076"
PASS=0
TOTAL=0

check_cluster

# ConfigMap에서 값 추출
CNI_PLUGIN=$(kubectl -n "$NAMESPACE" get configmap cni-info -o jsonpath='{.data.cni-plugin}' 2>/dev/null)
CONFIG_PATH=$(kubectl -n "$NAMESPACE" get configmap cni-info -o jsonpath='{.data.config-path}' 2>/dev/null)
POD_CIDR=$(kubectl -n "$NAMESPACE" get configmap cni-info -o jsonpath='{.data.pod-cidr}' 2>/dev/null)

# Task 1: cni-plugin에 유효한 CNI 이름이 있는지
TOTAL=$((TOTAL+1))
if [ -n "$CNI_PLUGIN" ] && ! echo "$CNI_PLUGIN" | grep -q 'TODO'; then
  # 알려진 CNI 플러그인 이름 또는 비어있지 않은 값
  print_pass "Task 1: CNI 플러그인 이름 기록됨 ($CNI_PLUGIN)"
  PASS=$((PASS+1))
else
  print_fail "Task 1: CNI 플러그인 이름이 기록되지 않음" "kube-system의 DaemonSet에서 CNI 플러그인을 확인하세요"
fi

# Task 2: config-path에 /etc/cni/net.d가 포함되어 있는지
TOTAL=$((TOTAL+1))
if echo "$CONFIG_PATH" | grep -q '/etc/cni/net.d'; then
  print_pass "Task 2: CNI 설정 경로가 올바름 ($CONFIG_PATH)"
  PASS=$((PASS+1))
else
  print_fail "Task 2: CNI 설정 경로가 올바르지 않음" "기본 경로는 /etc/cni/net.d/ 입니다"
fi

# Task 3: pod-cidr에 유효한 CIDR이 있는지
TOTAL=$((TOTAL+1))
if echo "$POD_CIDR" | grep -qE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+'; then
  print_pass "Task 3: Pod CIDR 기록됨 ($POD_CIDR)"
  PASS=$((PASS+1))
else
  print_fail "Task 3: Pod CIDR이 유효하지 않음" "kubectl get nodes -o jsonpath='{.items[0].spec.podCIDR}'로 확인하세요"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
