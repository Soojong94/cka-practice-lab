#!/bin/bash
# Problem 025: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q025"
PASS=0
TOTAL=0

check_cluster

# Task 1: ConfigMap 존재 여부
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get configmap etcd-commands &>/dev/null; then
  print_pass "Task 1: ConfigMap 'etcd-commands' 존재"
  PASS=$((PASS+1))
else
  print_fail "Task 1: ConfigMap 'etcd-commands' 미생성" "kubectl create configmap etcd-commands 명령을 사용하세요"
fi

# Task 2: ca-cert 경로 확인
TOTAL=$((TOTAL+1))
CA_CERT=$(kubectl -n "$NAMESPACE" get configmap etcd-commands -o jsonpath='{.data.ca-cert}' 2>/dev/null)
if [ "$CA_CERT" = "/etc/kubernetes/pki/etcd/ca.crt" ]; then
  print_pass "Task 2: 'ca-cert' 경로 올바름"
  PASS=$((PASS+1))
else
  print_fail "Task 2: 'ca-cert' 경로 불일치 (현재: $CA_CERT)" "--trusted-ca-file 값을 확인하세요"
fi

# Task 3: server-cert, server-key 경로 확인
TOTAL=$((TOTAL+1))
SERVER_CERT=$(kubectl -n "$NAMESPACE" get configmap etcd-commands -o jsonpath='{.data.server-cert}' 2>/dev/null)
SERVER_KEY=$(kubectl -n "$NAMESPACE" get configmap etcd-commands -o jsonpath='{.data.server-key}' 2>/dev/null)
if [ "$SERVER_CERT" = "/etc/kubernetes/pki/etcd/server.crt" ] && [ "$SERVER_KEY" = "/etc/kubernetes/pki/etcd/server.key" ]; then
  print_pass "Task 3: 'server-cert'와 'server-key' 경로 올바름"
  PASS=$((PASS+1))
else
  print_fail "Task 3: 인증서/키 경로 불일치 (cert: $SERVER_CERT, key: $SERVER_KEY)" "--cert-file, --key-file 값을 확인하세요"
fi

# Task 4: health-command 확인
TOTAL=$((TOTAL+1))
HEALTH_CMD=$(kubectl -n "$NAMESPACE" get configmap etcd-commands -o jsonpath='{.data.health-command}' 2>/dev/null)
if echo "$HEALTH_CMD" | grep -q "etcdctl" && \
   echo "$HEALTH_CMD" | grep -q "endpoint health" && \
   echo "$HEALTH_CMD" | grep -q "cacert" && \
   echo "$HEALTH_CMD" | grep -q "192.168.65.4:2379"; then
  print_pass "Task 4: 'health-command' 올바름"
  PASS=$((PASS+1))
else
  print_fail "Task 4: 'health-command' 불일치 (현재: $HEALTH_CMD)" "etcdctl --endpoints=... --cacert=... --cert=... --key=... endpoint health 형식을 사용하세요"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
