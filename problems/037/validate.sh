#!/bin/bash
# Problem 037: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q037"
PASS=0
TOTAL=0

check_cluster

# ConfigMap 존재 확인
if ! kubectl -n "$NAMESPACE" get configmap cluster-info &>/dev/null; then
  print_fail "ConfigMap 'cluster-info' 미존재"
  print_score 0 5
  exit 1
fi

# Task 1: kube-apiserver 정보 확인
TOTAL=$((TOTAL+1))
API_TYPE=$(kubectl -n "$NAMESPACE" get configmap cluster-info -o jsonpath='{.data.kube-apiserver-type}' 2>/dev/null)
API_NODE=$(kubectl -n "$NAMESPACE" get configmap cluster-info -o jsonpath='{.data.kube-apiserver-node}' 2>/dev/null)
API_IMAGE=$(kubectl -n "$NAMESPACE" get configmap cluster-info -o jsonpath='{.data.kube-apiserver-image}' 2>/dev/null)
if [ "$API_TYPE" = "static-pod" ] && [ -n "$API_NODE" ] && [ -n "$API_IMAGE" ] && [[ "$API_IMAGE" == *"kube-apiserver"* ]]; then
  print_pass "Task 1: kube-apiserver 정보 올바름 (type=$API_TYPE, node=$API_NODE)"
  PASS=$((PASS+1))
else
  print_fail "Task 1: kube-apiserver 정보 불완전 (type=$API_TYPE, node=$API_NODE, image=$API_IMAGE)" \
    "kube-apiserver는 static-pod로 실행됩니다"
fi

# Task 2: etcd 정보 확인
TOTAL=$((TOTAL+1))
ETCD_TYPE=$(kubectl -n "$NAMESPACE" get configmap cluster-info -o jsonpath='{.data.etcd-type}' 2>/dev/null)
ETCD_NODE=$(kubectl -n "$NAMESPACE" get configmap cluster-info -o jsonpath='{.data.etcd-node}' 2>/dev/null)
ETCD_IMAGE=$(kubectl -n "$NAMESPACE" get configmap cluster-info -o jsonpath='{.data.etcd-image}' 2>/dev/null)
if [ "$ETCD_TYPE" = "static-pod" ] && [ -n "$ETCD_NODE" ] && [ -n "$ETCD_IMAGE" ] && [[ "$ETCD_IMAGE" == *"etcd"* ]]; then
  print_pass "Task 2: etcd 정보 올바름 (type=$ETCD_TYPE, node=$ETCD_NODE)"
  PASS=$((PASS+1))
else
  print_fail "Task 2: etcd 정보 불완전 (type=$ETCD_TYPE, node=$ETCD_NODE, image=$ETCD_IMAGE)" \
    "etcd는 static-pod로 실행됩니다"
fi

# Task 3: kube-scheduler 정보 확인
TOTAL=$((TOTAL+1))
SCHED_TYPE=$(kubectl -n "$NAMESPACE" get configmap cluster-info -o jsonpath='{.data.kube-scheduler-type}' 2>/dev/null)
SCHED_NODE=$(kubectl -n "$NAMESPACE" get configmap cluster-info -o jsonpath='{.data.kube-scheduler-node}' 2>/dev/null)
SCHED_IMAGE=$(kubectl -n "$NAMESPACE" get configmap cluster-info -o jsonpath='{.data.kube-scheduler-image}' 2>/dev/null)
if [ "$SCHED_TYPE" = "static-pod" ] && [ -n "$SCHED_NODE" ] && [ -n "$SCHED_IMAGE" ] && [[ "$SCHED_IMAGE" == *"kube-scheduler"* ]]; then
  print_pass "Task 3: kube-scheduler 정보 올바름 (type=$SCHED_TYPE, node=$SCHED_NODE)"
  PASS=$((PASS+1))
else
  print_fail "Task 3: kube-scheduler 정보 불완전 (type=$SCHED_TYPE, node=$SCHED_NODE, image=$SCHED_IMAGE)" \
    "kube-scheduler는 static-pod로 실행됩니다"
fi

# Task 4: kube-controller-manager 정보 확인
TOTAL=$((TOTAL+1))
CM_TYPE=$(kubectl -n "$NAMESPACE" get configmap cluster-info -o jsonpath='{.data.kube-controller-manager-type}' 2>/dev/null)
CM_NODE=$(kubectl -n "$NAMESPACE" get configmap cluster-info -o jsonpath='{.data.kube-controller-manager-node}' 2>/dev/null)
CM_IMAGE=$(kubectl -n "$NAMESPACE" get configmap cluster-info -o jsonpath='{.data.kube-controller-manager-image}' 2>/dev/null)
if [ "$CM_TYPE" = "static-pod" ] && [ -n "$CM_NODE" ] && [ -n "$CM_IMAGE" ] && [[ "$CM_IMAGE" == *"kube-controller-manager"* ]]; then
  print_pass "Task 4: kube-controller-manager 정보 올바름 (type=$CM_TYPE, node=$CM_NODE)"
  PASS=$((PASS+1))
else
  print_fail "Task 4: kube-controller-manager 정보 불완전 (type=$CM_TYPE, node=$CM_NODE, image=$CM_IMAGE)" \
    "kube-controller-manager는 static-pod로 실행됩니다"
fi

# Task 5: coredns 정보 확인
TOTAL=$((TOTAL+1))
DNS_TYPE=$(kubectl -n "$NAMESPACE" get configmap cluster-info -o jsonpath='{.data.coredns-type}' 2>/dev/null)
DNS_NODE=$(kubectl -n "$NAMESPACE" get configmap cluster-info -o jsonpath='{.data.coredns-node}' 2>/dev/null)
DNS_IMAGE=$(kubectl -n "$NAMESPACE" get configmap cluster-info -o jsonpath='{.data.coredns-image}' 2>/dev/null)
if [ "$DNS_TYPE" = "deployment" ] && [ -n "$DNS_NODE" ] && [ -n "$DNS_IMAGE" ] && [[ "$DNS_IMAGE" == *"coredns"* ]]; then
  print_pass "Task 5: coredns 정보 올바름 (type=$DNS_TYPE, node=$DNS_NODE)"
  PASS=$((PASS+1))
else
  print_fail "Task 5: coredns 정보 불완전 (type=$DNS_TYPE, node=$DNS_NODE, image=$DNS_IMAGE)" \
    "coredns는 deployment로 실행됩니다"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
