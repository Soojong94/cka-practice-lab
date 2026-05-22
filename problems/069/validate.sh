#!/bin/bash
# Problem 069: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q069"
PASS=0
TOTAL=0

check_cluster

# 실제 namespaced 리소스 수 계산
ACTUAL_NS_COUNT=$(kubectl api-resources --namespaced=true --no-headers 2>/dev/null | wc -l | tr -d ' ')

# Task 1: namespaced-count 확인
TOTAL=$((TOTAL+1))
NS_COUNT=$(kubectl -n "$NAMESPACE" get configmap api-info -o jsonpath='{.data.namespaced-count}' 2>/dev/null)
if [ -n "$NS_COUNT" ] && [ "$NS_COUNT" = "$ACTUAL_NS_COUNT" ]; then
  print_pass "Task 1: namespaced-count = $NS_COUNT (정확)"
  PASS=$((PASS+1))
else
  print_fail "Task 1: namespaced-count 불일치 (현재: '$NS_COUNT', 실제: '$ACTUAL_NS_COUNT')" \
    "kubectl api-resources --namespaced=true --no-headers | wc -l"
fi

# Task 2: deployments-apigroup 확인
TOTAL=$((TOTAL+1))
DEPLOY_GROUP=$(kubectl -n "$NAMESPACE" get configmap api-info -o jsonpath='{.data.deployments-apigroup}' 2>/dev/null)
if [ "$DEPLOY_GROUP" = "apps" ]; then
  print_pass "Task 2: deployments-apigroup = apps"
  PASS=$((PASS+1))
else
  print_fail "Task 2: deployments-apigroup 불일치 (현재: '$DEPLOY_GROUP')" \
    "kubectl api-resources | grep deployments 에서 APIVERSION 컬럼 확인"
fi

# Task 3: cronjobs-namespaced 확인
TOTAL=$((TOTAL+1))
CRONJOBS_NS=$(kubectl -n "$NAMESPACE" get configmap api-info -o jsonpath='{.data.cronjobs-namespaced}' 2>/dev/null)
if [ "$CRONJOBS_NS" = "true" ]; then
  print_pass "Task 3: cronjobs-namespaced = true"
  PASS=$((PASS+1))
else
  print_fail "Task 3: cronjobs-namespaced 불일치 (현재: '$CRONJOBS_NS')" \
    "kubectl api-resources | grep cronjobs 에서 NAMESPACED 컬럼 확인"
fi

# Task 4: nodes-namespaced 확인
TOTAL=$((TOTAL+1))
NODES_NS=$(kubectl -n "$NAMESPACE" get configmap api-info -o jsonpath='{.data.nodes-namespaced}' 2>/dev/null)
if [ "$NODES_NS" = "false" ]; then
  print_pass "Task 4: nodes-namespaced = false"
  PASS=$((PASS+1))
else
  print_fail "Task 4: nodes-namespaced 불일치 (현재: '$NODES_NS')" \
    "nodes는 클러스터 범위 리소스입니다"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
