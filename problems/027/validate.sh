#!/bin/bash
# Problem 027: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q027"
PASS=0
TOTAL=0

check_cluster

# Task 1: Deployment Available 상태
TOTAL=$((TOTAL+1))
AVAILABLE=$(kubectl -n "$NAMESPACE" get deployment web-deploy -o jsonpath='{.status.conditions[?(@.type=="Available")].status}' 2>/dev/null)
if [ "$AVAILABLE" = "True" ]; then
  print_pass "Task 1: Deployment 'web-deploy' Available 상태"
  PASS=$((PASS+1))
else
  print_fail "Task 1: Deployment 'web-deploy' Available 아님" "kubectl rollout undo로 롤백하세요"
fi

# Task 2: 모든 replicas Ready
TOTAL=$((TOTAL+1))
READY_REPLICAS=$(kubectl -n "$NAMESPACE" get deployment web-deploy -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
DESIRED_REPLICAS=$(kubectl -n "$NAMESPACE" get deployment web-deploy -o jsonpath='{.spec.replicas}' 2>/dev/null)
if [ "$READY_REPLICAS" = "$DESIRED_REPLICAS" ] && [ "$READY_REPLICAS" = "3" ]; then
  print_pass "Task 2: 모든 replicas Ready ($READY_REPLICAS/$DESIRED_REPLICAS)"
  PASS=$((PASS+1))
else
  print_fail "Task 2: replicas 불일치 (ready: $READY_REPLICAS, desired: $DESIRED_REPLICAS)" "3개의 replica가 모두 Ready여야 합니다"
fi

# Task 3: 이미지가 원래 이미지(nginx:alpine)로 복구됨
TOTAL=$((TOTAL+1))
CURRENT_IMAGE=$(kubectl -n "$NAMESPACE" get deployment web-deploy -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
if [ "$CURRENT_IMAGE" = "nginx:alpine" ]; then
  print_pass "Task 3: 이미지 복구됨 (nginx:alpine)"
  PASS=$((PASS+1))
else
  print_fail "Task 3: 이미지 불일치 (현재: $CURRENT_IMAGE, 기대: nginx:alpine)" "이전 버전으로 롤백하세요"
fi

# Task 4: rollout 상태 확인
TOTAL=$((TOTAL+1))
ROLLOUT_STATUS=$(kubectl -n "$NAMESPACE" rollout status deployment/web-deploy --timeout=10s 2>&1)
if echo "$ROLLOUT_STATUS" | grep -q "successfully rolled out"; then
  print_pass "Task 4: Rollout 성공적으로 완료"
  PASS=$((PASS+1))
else
  print_fail "Task 4: Rollout 미완료" "kubectl rollout status로 확인하세요"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
