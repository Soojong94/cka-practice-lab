#!/bin/bash
# Problem 062: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q062"
PASS=0
TOTAL=0

check_cluster

# Task 1: Helm 릴리스 존재 확인
TOTAL=$((TOTAL+1))
RELEASE_STATUS=$(helm list -n "$NAMESPACE" -o json 2>/dev/null | grep -o '"name":"web-release"' 2>/dev/null)
if [ -n "$RELEASE_STATUS" ]; then
  print_pass "Task 1: Helm 릴리스 'web-release' 존재"
  PASS=$((PASS+1))
else
  print_fail "Task 1: Helm 릴리스 'web-release' 미존재" \
    "helm install web-release bitnami/nginx -n cka-q062"
fi

# Task 2: 릴리스 상태가 deployed
TOTAL=$((TOTAL+1))
DEPLOY_STATUS=$(helm status web-release -n "$NAMESPACE" -o json 2>/dev/null | grep -o '"status":"deployed"' 2>/dev/null)
if [ -n "$DEPLOY_STATUS" ]; then
  print_pass "Task 2: 릴리스 상태 'deployed'"
  PASS=$((PASS+1))
else
  print_fail "Task 2: 릴리스 상태가 deployed 아님" \
    "helm status web-release -n cka-q062 으로 확인하세요"
fi

# Task 3: Deployment replicas 확인
TOTAL=$((TOTAL+1))
REPLICAS=$(kubectl -n "$NAMESPACE" get deployment -l app.kubernetes.io/instance=web-release -o jsonpath='{.items[0].spec.replicas}' 2>/dev/null)
if [ "$REPLICAS" = "2" ]; then
  print_pass "Task 3: Deployment replicas = 2"
  PASS=$((PASS+1))
else
  print_fail "Task 3: Deployment replicas 불일치 (현재: '$REPLICAS')" \
    "helm upgrade web-release bitnami/nginx -n cka-q062 --set replicaCount=2"
fi

# Task 4: 릴리스 revision 확인
TOTAL=$((TOTAL+1))
REVISION=$(helm history web-release -n "$NAMESPACE" 2>/dev/null | tail -1 | awk '{print $1}')
if [ -n "$REVISION" ] && [ "$REVISION" -ge 2 ] 2>/dev/null; then
  print_pass "Task 4: 릴리스 revision >= 2 (현재: $REVISION)"
  PASS=$((PASS+1))
else
  print_fail "Task 4: 릴리스 revision < 2 (현재: '$REVISION')" \
    "helm upgrade를 수행하면 revision이 증가합니다"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
