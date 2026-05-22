#!/bin/bash
# Problem 032: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q032"
PASS=0
TOTAL=0

check_cluster

# Task 1: Pod 존재 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get pod memory-hog &>/dev/null; then
  print_pass "Task 1: Pod 'memory-hog' 존재"
  PASS=$((PASS+1))
else
  print_fail "Task 1: Pod 'memory-hog' 미존재" \
    "Pod를 재생성하세요"
fi

# Task 2: Pod Running 상태 확인
TOTAL=$((TOTAL+1))
POD_STATUS=$(kubectl -n "$NAMESPACE" get pod memory-hog -o jsonpath='{.status.phase}' 2>/dev/null)
CONTAINER_STATE=$(kubectl -n "$NAMESPACE" get pod memory-hog -o jsonpath='{.status.containerStatuses[0].state.running}' 2>/dev/null)
if [ "$POD_STATUS" = "Running" ] && [ -n "$CONTAINER_STATE" ]; then
  print_pass "Task 2: Pod 'memory-hog' Running 상태"
  PASS=$((PASS+1))
else
  # OOMKilled 확인
  LAST_REASON=$(kubectl -n "$NAMESPACE" get pod memory-hog -o jsonpath='{.status.containerStatuses[0].lastState.terminated.reason}' 2>/dev/null)
  CURRENT_REASON=$(kubectl -n "$NAMESPACE" get pod memory-hog -o jsonpath='{.status.containerStatuses[0].state.waiting.reason}' 2>/dev/null)
  print_fail "Task 2: Pod 'memory-hog' Running 아님 (phase=$POD_STATUS, lastReason=$LAST_REASON, waitReason=$CURRENT_REASON)" \
    "메모리 limit을 128Mi로 증가시키세요"
fi

# Task 3: 메모리 limit 확인
TOTAL=$((TOTAL+1))
MEM_LIMIT=$(kubectl -n "$NAMESPACE" get pod memory-hog -o jsonpath='{.spec.containers[0].resources.limits.memory}' 2>/dev/null)
if [ "$MEM_LIMIT" = "128Mi" ]; then
  print_pass "Task 3: 메모리 limit '128Mi' 올바르게 설정됨"
  PASS=$((PASS+1))
else
  print_fail "Task 3: 메모리 limit 불일치 (현재: $MEM_LIMIT, 기대: 128Mi)" \
    "resources.limits.memory를 128Mi로 설정하세요"
fi

# Task 4: OOMKilled 아닌지 확인 (최근 재시작 사유)
TOTAL=$((TOTAL+1))
RESTART_COUNT=$(kubectl -n "$NAMESPACE" get pod memory-hog -o jsonpath='{.status.containerStatuses[0].restartCount}' 2>/dev/null)
LAST_TERMINATED=$(kubectl -n "$NAMESPACE" get pod memory-hog -o jsonpath='{.status.containerStatuses[0].lastState.terminated.reason}' 2>/dev/null)
if [ "${RESTART_COUNT:-0}" -eq 0 ] && [ "$LAST_TERMINATED" != "OOMKilled" ]; then
  print_pass "Task 4: OOMKilled 없이 정상 동작 중"
  PASS=$((PASS+1))
else
  print_fail "Task 4: OOMKilled 발생 또는 재시작됨 (restarts=$RESTART_COUNT, lastReason=$LAST_TERMINATED)" \
    "메모리 limit을 충분히 높게 설정하세요"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
