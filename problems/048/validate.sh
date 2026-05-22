#!/bin/bash
# Problem 048: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q048"
PASS=0
TOTAL=0

check_cluster

# Task 1: CronJob 존재 및 스케줄 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get cronjob backup-cron &>/dev/null; then
  SCHEDULE=$(kubectl -n "$NAMESPACE" get cronjob backup-cron -o jsonpath='{.spec.schedule}')
  if [ "$SCHEDULE" = "*/5 * * * *" ]; then
    print_pass "Task 1: CronJob 'backup-cron' 올바른 스케줄 (*/5 * * * *)"
    PASS=$((PASS+1))
  else
    print_fail "Task 1: CronJob 스케줄 불일치 (현재: $SCHEDULE)" \
      "schedule: '*/5 * * * *' 확인"
  fi
else
  print_fail "Task 1: CronJob 'backup-cron' 미생성" "kubectl -n $NAMESPACE create cronjob으로 생성하세요"
fi

# Task 2: 이미지 및 명령 확인
TOTAL=$((TOTAL+1))
IMAGE=$(kubectl -n "$NAMESPACE" get cronjob backup-cron -o jsonpath='{.spec.jobTemplate.spec.template.spec.containers[0].image}' 2>/dev/null)
COMMAND=$(kubectl -n "$NAMESPACE" get cronjob backup-cron -o jsonpath='{.spec.jobTemplate.spec.template.spec.containers[0].command}' 2>/dev/null)
if [ "$IMAGE" = "busybox" ] && echo "$COMMAND" | grep -q "backup-done"; then
  print_pass "Task 2: 이미지(busybox) 및 명령(echo backup-done) 올바름"
  PASS=$((PASS+1))
else
  print_fail "Task 2: 이미지 또는 명령 불일치 (image=$IMAGE)" \
    "image: busybox, command: echo backup-done 확인"
fi

# Task 3: 히스토리 제한 확인
TOTAL=$((TOTAL+1))
SUCCESS_LIMIT=$(kubectl -n "$NAMESPACE" get cronjob backup-cron -o jsonpath='{.spec.successfulJobsHistoryLimit}' 2>/dev/null)
FAILED_LIMIT=$(kubectl -n "$NAMESPACE" get cronjob backup-cron -o jsonpath='{.spec.failedJobsHistoryLimit}' 2>/dev/null)
if [ "$SUCCESS_LIMIT" = "3" ] && [ "$FAILED_LIMIT" = "1" ]; then
  print_pass "Task 3: 히스토리 제한 올바름 (success=3, failed=1)"
  PASS=$((PASS+1))
else
  print_fail "Task 3: 히스토리 제한 불일치 (success=$SUCCESS_LIMIT, failed=$FAILED_LIMIT)" \
    "successfulJobsHistoryLimit: 3, failedJobsHistoryLimit: 1 설정"
fi

# Task 4: concurrencyPolicy 확인
TOTAL=$((TOTAL+1))
CONCURRENCY=$(kubectl -n "$NAMESPACE" get cronjob backup-cron -o jsonpath='{.spec.concurrencyPolicy}' 2>/dev/null)
if [ "$CONCURRENCY" = "Forbid" ]; then
  print_pass "Task 4: concurrencyPolicy=Forbid 설정됨"
  PASS=$((PASS+1))
else
  print_fail "Task 4: concurrencyPolicy 불일치 (현재: $CONCURRENCY)" \
    "concurrencyPolicy: Forbid 설정"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
