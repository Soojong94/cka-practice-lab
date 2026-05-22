#!/bin/bash
# Problem 012: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q012"
PASS=0
TOTAL=0

check_cluster

# Task 1: Deployment 존재 여부 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get deployment web-deploy &>/dev/null; then
  print_pass "Task 1: Deployment 'web-deploy' 존재 확인"
  PASS=$((PASS+1))
else
  print_fail "Task 1: Deployment 'web-deploy' 미존재" "Deployment를 확인하세요"
fi

# Task 2: 올바른 이미지 이름 확인
TOTAL=$((TOTAL+1))
IMAGE=$(kubectl -n "$NAMESPACE" get deployment web-deploy -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
if [ "$IMAGE" = "nginx:latest" ] || [ "$IMAGE" = "nginx" ]; then
  print_pass "Task 2: 올바른 이미지 'nginx:latest' 설정됨"
  PASS=$((PASS+1))
else
  print_fail "Task 2: 이미지가 올바르지 않음 (현재: $IMAGE)" \
    "이미지를 'nginx:latest'로 수정하세요"
fi

# Task 3: Deployment Available 상태 확인
TOTAL=$((TOTAL+1))
AVAILABLE=$(kubectl -n "$NAMESPACE" get deployment web-deploy -o jsonpath='{.status.availableReplicas}' 2>/dev/null)
if [ "$AVAILABLE" = "3" ]; then
  print_pass "Task 3: Deployment Available 레플리카 3개 확인"
  PASS=$((PASS+1))
else
  print_fail "Task 3: Available 레플리카 부족 (현재: ${AVAILABLE:-0})" \
    "이미지 수정 후 롤아웃이 완료될 때까지 기다리세요"
fi

# Task 4: 모든 Pod Running 상태 확인
TOTAL=$((TOTAL+1))
RUNNING_COUNT=$(kubectl -n "$NAMESPACE" get pods -l app=web-deploy --field-selector=status.phase=Running --no-headers 2>/dev/null | wc -l)
if [ "$RUNNING_COUNT" -ge 3 ]; then
  print_pass "Task 4: 모든 Pod Running 상태 (${RUNNING_COUNT}개)"
  PASS=$((PASS+1))
else
  print_fail "Task 4: Running Pod 부족 (현재: ${RUNNING_COUNT}개)" \
    "Pod 상태를 확인하세요: kubectl -n $NAMESPACE get pods"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
