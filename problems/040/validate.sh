#!/bin/bash
# Problem 040: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q040"
PASS=0
TOTAL=0

check_cluster

# Task 1: 스크립트 파일 존재 확인
TOTAL=$((TOTAL+1))
if [ -f /tmp/cka-q040-events.sh ]; then
  print_pass "Task 1: 스크립트 파일 '/tmp/cka-q040-events.sh' 존재"
  PASS=$((PASS+1))
else
  print_fail "Task 1: 스크립트 파일 '/tmp/cka-q040-events.sh' 미존재" \
    "스크립트 파일을 생성하세요"
fi

# Task 2: 스크립트 실행 권한 확인
TOTAL=$((TOTAL+1))
if [ -x /tmp/cka-q040-events.sh ]; then
  print_pass "Task 2: 스크립트 파일에 실행 권한 있음"
  PASS=$((PASS+1))
else
  print_fail "Task 2: 스크립트 파일에 실행 권한 없음" \
    "chmod +x /tmp/cka-q040-events.sh"
fi

# Task 3: 스크립트에 시간순 정렬 명령 포함 확인
TOTAL=$((TOTAL+1))
if grep -q "sort-by" /tmp/cka-q040-events.sh 2>/dev/null && grep -q "events" /tmp/cka-q040-events.sh 2>/dev/null; then
  print_pass "Task 3: 스크립트에 이벤트 시간순 정렬 명령 포함"
  PASS=$((PASS+1))
else
  print_fail "Task 3: 스크립트에 이벤트 시간순 정렬 명령 미포함" \
    "kubectl get events --sort-by='.lastTimestamp' 명령을 포함하세요"
fi

# Task 4: 스크립트에 Warning 필터 명령 포함 확인
TOTAL=$((TOTAL+1))
if grep -q "Warning" /tmp/cka-q040-events.sh 2>/dev/null || grep -q "type=Warning" /tmp/cka-q040-events.sh 2>/dev/null; then
  print_pass "Task 4: 스크립트에 Warning 이벤트 필터 명령 포함"
  PASS=$((PASS+1))
else
  print_fail "Task 4: 스크립트에 Warning 이벤트 필터 명령 미포함" \
    "--field-selector type=Warning 을 포함하세요"
fi

# Task 5: ConfigMap event-analysis 존재 및 내용 확인
TOTAL=$((TOTAL+1))
REASON=$(kubectl -n "$NAMESPACE" get configmap event-analysis -o jsonpath='{.data.failing-pod-reason}' 2>/dev/null)
if [[ "$REASON" == *"ImagePull"* ]] || [[ "$REASON" == *"ErrImage"* ]] || [[ "$REASON" == *"BackOff"* ]]; then
  print_pass "Task 5: ConfigMap 'event-analysis'에 실패 원인 기록됨 ($REASON)"
  PASS=$((PASS+1))
else
  print_fail "Task 5: ConfigMap 'event-analysis' 미존재 또는 원인 미기록 (현재: $REASON)" \
    "failing-pod-reason에 ImagePullBackOff 또는 ErrImagePull을 기록하세요"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
