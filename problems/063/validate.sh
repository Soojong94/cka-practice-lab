#!/bin/bash
# Problem 063: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q063"
PASS=0
TOTAL=0

check_cluster

# Task 1: Service 타입 확인
TOTAL=$((TOTAL+1))
SVC_TYPE=$(kubectl -n "$NAMESPACE" get svc -l app.kubernetes.io/instance=custom-app -o jsonpath='{.items[0].spec.type}' 2>/dev/null)
if [ "$SVC_TYPE" = "NodePort" ]; then
  print_pass "Task 1: Service 타입 = NodePort"
  PASS=$((PASS+1))
else
  print_fail "Task 1: Service 타입 불일치 (현재: '$SVC_TYPE')" \
    "helm upgrade --set service.type=NodePort"
fi

# Task 2: Deployment에 team=platform 레이블 확인
TOTAL=$((TOTAL+1))
TEAM_LABEL=$(kubectl -n "$NAMESPACE" get deployment -l app.kubernetes.io/instance=custom-app -o jsonpath='{.items[0].metadata.labels.team}' 2>/dev/null)
if [ "$TEAM_LABEL" = "platform" ]; then
  print_pass "Task 2: Deployment에 team=platform 레이블 존재"
  PASS=$((PASS+1))
else
  print_fail "Task 2: Deployment에 team=platform 레이블 미존재 (현재: '$TEAM_LABEL')" \
    "helm upgrade --set commonLabels.team=platform"
fi

# Task 3: 릴리스 revision 확인
TOTAL=$((TOTAL+1))
REVISION=$(helm history custom-app -n "$NAMESPACE" 2>/dev/null | tail -1 | awk '{print $1}')
if [ -n "$REVISION" ] && [ "$REVISION" -ge 2 ] 2>/dev/null; then
  print_pass "Task 3: 릴리스 revision >= 2 (현재: $REVISION)"
  PASS=$((PASS+1))
else
  print_fail "Task 3: 릴리스 revision < 2 (현재: '$REVISION')" \
    "helm upgrade를 수행하면 revision이 증가합니다"
fi

# Task 4: 릴리스 상태 deployed
TOTAL=$((TOTAL+1))
DEPLOY_STATUS=$(helm status custom-app -n "$NAMESPACE" -o json 2>/dev/null | grep -o '"status":"deployed"' 2>/dev/null)
if [ -n "$DEPLOY_STATUS" ]; then
  print_pass "Task 4: 릴리스 상태 'deployed'"
  PASS=$((PASS+1))
else
  print_fail "Task 4: 릴리스 상태가 deployed 아님" \
    "helm status custom-app -n cka-q063 으로 확인하세요"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
