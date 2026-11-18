#!/bin/bash
# Problem 029: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q029"
PASS=0
TOTAL=0

check_cluster

# 실제 Service IP 가져오기
ACTUAL_SVC_IP=$(kubectl -n "$NAMESPACE" get svc test-svc -o jsonpath='{.spec.clusterIP}' 2>/dev/null)

# Task 1: ConfigMap 존재 여부
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get configmap service-cidr-answer &>/dev/null; then
  print_pass "Task 1: ConfigMap 'service-cidr-answer' 존재"
  PASS=$((PASS+1))
else
  print_fail "Task 1: ConfigMap 'service-cidr-answer' 미생성" "kubectl create configmap service-cidr-answer 명령을 사용하세요"
fi

# Task 2: service-cidr 값 확인
TOTAL=$((TOTAL+1))
SVC_CIDR=$(kubectl -n "$NAMESPACE" get configmap service-cidr-answer -o jsonpath='{.data.service-cidr}' 2>/dev/null)
if [ "$SVC_CIDR" = "10.96.0.0/12" ]; then
  print_pass "Task 2: 'service-cidr' 값 올바름 ($SVC_CIDR)"
  PASS=$((PASS+1))
else
  print_fail "Task 2: 'service-cidr' 값 불일치 (현재: $SVC_CIDR, 기대: 10.96.0.0/12)" "--service-cluster-ip-range 값을 확인하세요"
fi

# Task 3: test-svc-ip 값 확인
TOTAL=$((TOTAL+1))
CM_SVC_IP=$(kubectl -n "$NAMESPACE" get configmap service-cidr-answer -o jsonpath='{.data.test-svc-ip}' 2>/dev/null)
if [ "$CM_SVC_IP" = "$ACTUAL_SVC_IP" ]; then
  print_pass "Task 3: 'test-svc-ip' 값 올바름 ($CM_SVC_IP)"
  PASS=$((PASS+1))
else
  print_fail "Task 3: 'test-svc-ip' 값 불일치 (현재: $CM_SVC_IP, 기대: $ACTUAL_SVC_IP)" "kubectl get svc test-svc로 ClusterIP를 확인하세요"
fi

# Task 4: manifest-path 값 확인
TOTAL=$((TOTAL+1))
MANIFEST_PATH=$(kubectl -n "$NAMESPACE" get configmap service-cidr-answer -o jsonpath='{.data.manifest-path}' 2>/dev/null)
MANIFEST_PATH=$(unmangle_path "$MANIFEST_PATH")
if [ "$MANIFEST_PATH" = "/etc/kubernetes/manifests/kube-apiserver.yaml" ]; then
  print_pass "Task 4: 'manifest-path' 값 올바름"
  PASS=$((PASS+1))
else
  print_fail "Task 4: 'manifest-path' 값 불일치 (현재: $MANIFEST_PATH)" "static pod manifest 경로는 /etc/kubernetes/manifests/ 입니다"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
