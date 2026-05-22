#!/bin/bash
# Problem 049: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q049"
PASS=0
TOTAL=0

check_cluster

# Task 1: Rolling Update 전략 확인
TOTAL=$((TOTAL+1))
STRATEGY=$(kubectl -n "$NAMESPACE" get deployment web -o jsonpath='{.spec.strategy.type}' 2>/dev/null)
MAX_SURGE=$(kubectl -n "$NAMESPACE" get deployment web -o jsonpath='{.spec.strategy.rollingUpdate.maxSurge}' 2>/dev/null)
MAX_UNAVAIL=$(kubectl -n "$NAMESPACE" get deployment web -o jsonpath='{.spec.strategy.rollingUpdate.maxUnavailable}' 2>/dev/null)
if [ "$STRATEGY" = "RollingUpdate" ] && [ "$MAX_SURGE" = "1" ] && [ "$MAX_UNAVAIL" = "0" ]; then
  print_pass "Task 1: Rolling Update 전략 올바름 (maxSurge=1, maxUnavailable=0)"
  PASS=$((PASS+1))
else
  print_fail "Task 1: 전략 불일치 (type=$STRATEGY, maxSurge=$MAX_SURGE, maxUnavailable=$MAX_UNAVAIL)" \
    "strategy.rollingUpdate에 maxSurge: 1, maxUnavailable: 0 설정"
fi

# Task 2: 현재 이미지 확인 (롤백 후 1.24-alpine)
TOTAL=$((TOTAL+1))
IMAGE=$(kubectl -n "$NAMESPACE" get deployment web -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
if [ "$IMAGE" = "nginx:1.24-alpine" ]; then
  print_pass "Task 2: 이미지 롤백 완료 (nginx:1.24-alpine)"
  PASS=$((PASS+1))
else
  print_fail "Task 2: 이미지 불일치 (현재: $IMAGE, 기대: nginx:1.24-alpine)" \
    "kubectl rollout undo로 롤백하세요"
fi

# Task 3: 롤아웃 히스토리 확인 (2개 이상 리비전)
TOTAL=$((TOTAL+1))
REVISION_COUNT=$(kubectl -n "$NAMESPACE" rollout history deployment/web 2>/dev/null | grep -c "^[0-9]")
if [ "$REVISION_COUNT" -ge 2 ]; then
  print_pass "Task 3: 롤아웃 히스토리에 ${REVISION_COUNT}개 리비전 존재"
  PASS=$((PASS+1))
else
  print_fail "Task 3: 롤아웃 히스토리 부족 (현재: ${REVISION_COUNT}개)" \
    "이미지 업데이트 후 롤백하면 2개 이상의 리비전이 생깁니다"
fi

# Task 4: Deployment Ready 확인
TOTAL=$((TOTAL+1))
READY=$(kubectl -n "$NAMESPACE" get deployment web -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
REPLICAS=$(kubectl -n "$NAMESPACE" get deployment web -o jsonpath='{.spec.replicas}' 2>/dev/null)
if [ "$READY" = "$REPLICAS" ] && [ "$REPLICAS" = "4" ]; then
  print_pass "Task 4: Deployment 정상 (4/4 Ready)"
  PASS=$((PASS+1))
else
  print_fail "Task 4: Deployment 상태 불일치 (ready=$READY, replicas=$REPLICAS)" \
    "모든 Pod가 Running 상태여야 합니다"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
