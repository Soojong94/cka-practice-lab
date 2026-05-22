#!/bin/bash
# Problem 026: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q026"
PASS=0
TOTAL=0

check_cluster

# Task 1: app-crash Pod Running 상태
TOTAL=$((TOTAL+1))
CRASH_STATUS=$(kubectl -n "$NAMESPACE" get pod app-crash -o jsonpath='{.status.phase}' 2>/dev/null)
if [ "$CRASH_STATUS" = "Running" ]; then
  print_pass "Task 1: Pod 'app-crash' Running 상태"
  PASS=$((PASS+1))
else
  print_fail "Task 1: Pod 'app-crash' Running 아님 (현재: $CRASH_STATUS)" "command를 수정하여 컨테이너가 종료되지 않도록 하세요"
fi

# Task 2: app-crash Pod Ready
TOTAL=$((TOTAL+1))
CRASH_READY=$(kubectl -n "$NAMESPACE" get pod app-crash -o jsonpath='{.status.containerStatuses[0].ready}' 2>/dev/null)
if [ "$CRASH_READY" = "true" ]; then
  print_pass "Task 2: Pod 'app-crash' Ready 상태"
  PASS=$((PASS+1))
else
  print_fail "Task 2: Pod 'app-crash' Ready 아님" "컨테이너가 정상 실행 중인지 확인하세요"
fi

# Task 3: app-imagepull Pod Running 상태
TOTAL=$((TOTAL+1))
IMG_STATUS=$(kubectl -n "$NAMESPACE" get pod app-imagepull -o jsonpath='{.status.phase}' 2>/dev/null)
if [ "$IMG_STATUS" = "Running" ]; then
  print_pass "Task 3: Pod 'app-imagepull' Running 상태"
  PASS=$((PASS+1))
else
  print_fail "Task 3: Pod 'app-imagepull' Running 아님 (현재: $IMG_STATUS)" "유효한 이미지 태그를 사용하세요"
fi

# Task 4: app-imagepull Pod Ready
TOTAL=$((TOTAL+1))
IMG_READY=$(kubectl -n "$NAMESPACE" get pod app-imagepull -o jsonpath='{.status.containerStatuses[0].ready}' 2>/dev/null)
if [ "$IMG_READY" = "true" ]; then
  print_pass "Task 4: Pod 'app-imagepull' Ready 상태"
  PASS=$((PASS+1))
else
  print_fail "Task 4: Pod 'app-imagepull' Ready 아님" "이미지를 nginx:alpine으로 변경하세요"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
