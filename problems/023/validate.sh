#!/bin/bash
# Problem 023: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q023"
PASS=0
TOTAL=0

check_cluster

# 실제 ClusterIP 가져오기
ACTUAL_CLUSTER_IP=$(kubectl -n "$NAMESPACE" get svc web-svc -o jsonpath='{.spec.clusterIP}' 2>/dev/null)

# Task 1: ConfigMap 존재 여부
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get configmap kube-proxy-analysis &>/dev/null; then
  print_pass "Task 1: ConfigMap 'kube-proxy-analysis' 존재"
  PASS=$((PASS+1))
else
  print_fail "Task 1: ConfigMap 'kube-proxy-analysis' 미생성" "kubectl create configmap kube-proxy-analysis 명령을 사용하세요"
fi

# Task 2: cluster-ip 값 확인
TOTAL=$((TOTAL+1))
CM_CLUSTER_IP=$(kubectl -n "$NAMESPACE" get configmap kube-proxy-analysis -o jsonpath='{.data.cluster-ip}' 2>/dev/null)
if [ "$CM_CLUSTER_IP" = "$ACTUAL_CLUSTER_IP" ]; then
  print_pass "Task 2: 'cluster-ip' 값 올바름 ($CM_CLUSTER_IP)"
  PASS=$((PASS+1))
else
  print_fail "Task 2: 'cluster-ip' 값 불일치 (현재: $CM_CLUSTER_IP, 기대: $ACTUAL_CLUSTER_IP)" "kubectl get svc web-svc로 ClusterIP를 확인하세요"
fi

# Task 3: endpoint-count 값 확인
TOTAL=$((TOTAL+1))
EP_COUNT=$(kubectl -n "$NAMESPACE" get configmap kube-proxy-analysis -o jsonpath='{.data.endpoint-count}' 2>/dev/null)
if [ "$EP_COUNT" = "2" ]; then
  print_pass "Task 3: 'endpoint-count' 값 올바름 (2)"
  PASS=$((PASS+1))
else
  print_fail "Task 3: 'endpoint-count' 값 불일치 (현재: $EP_COUNT, 기대: 2)" "kubectl get endpoints web-svc로 Endpoint 수를 확인하세요"
fi

# Task 4: iptables-chain 값 확인
TOTAL=$((TOTAL+1))
CHAIN=$(kubectl -n "$NAMESPACE" get configmap kube-proxy-analysis -o jsonpath='{.data.iptables-chain}' 2>/dev/null)
if echo "$CHAIN" | grep -q "KUBE-SVC"; then
  print_pass "Task 4: 'iptables-chain' 값 올바름 ($CHAIN)"
  PASS=$((PASS+1))
else
  print_fail "Task 4: 'iptables-chain' 값 불일치 (현재: $CHAIN)" "kube-proxy는 KUBE-SVC 체인을 생성합니다"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
