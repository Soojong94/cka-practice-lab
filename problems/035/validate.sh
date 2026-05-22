#!/bin/bash
# Problem 035: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q035"
PASS=0
TOTAL=0

check_cluster

# Task 1: Job 존재 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get job data-process &>/dev/null; then
  print_pass "Task 1: Job 'data-process' 존재"
  PASS=$((PASS+1))
else
  print_fail "Task 1: Job 'data-process' 미존재" \
    "새 Job을 생성하세요"
fi

# Task 2: Job 성공 확인
TOTAL=$((TOTAL+1))
SUCCEEDED=$(kubectl -n "$NAMESPACE" get job data-process -o jsonpath='{.status.succeeded}' 2>/dev/null)
if [ "$SUCCEEDED" = "1" ]; then
  print_pass "Task 2: Job 'data-process' 성공 완료"
  PASS=$((PASS+1))
else
  FAILED=$(kubectl -n "$NAMESPACE" get job data-process -o jsonpath='{.status.failed}' 2>/dev/null)
  print_fail "Task 2: Job 'data-process' 미완료 (succeeded=$SUCCEEDED, failed=$FAILED)" \
    "명령어를 exit 0으로 수정하세요"
fi

# Task 3: Job의 Pod가 Completed 상태인지
TOTAL=$((TOTAL+1))
POD_STATUS=$(kubectl -n "$NAMESPACE" get pods -l job-name=data-process --field-selector=status.phase=Succeeded -o name 2>/dev/null)
if [ -n "$POD_STATUS" ]; then
  print_pass "Task 3: Job Pod가 Succeeded 상태"
  PASS=$((PASS+1))
else
  print_fail "Task 3: Job Pod가 Succeeded 상태 아님" \
    "Job 명령어가 exit 0으로 정상 종료되어야 합니다"
fi

# Task 4: Job 명령어에 exit 1이 없는지 확인
TOTAL=$((TOTAL+1))
JOB_CMD=$(kubectl -n "$NAMESPACE" get job data-process -o jsonpath='{.spec.template.spec.containers[0].command}' 2>/dev/null)
if [[ "$JOB_CMD" != *"exit 1"* ]]; then
  print_pass "Task 4: Job 명령어에 'exit 1' 없음 (수정됨)"
  PASS=$((PASS+1))
else
  print_fail "Task 4: Job 명령어에 여전히 'exit 1' 포함" \
    "명령어를 수정하여 정상 종료되도록 하세요"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
