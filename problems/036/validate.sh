#!/bin/bash
# Problem 036: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q036"
PASS=0
TOTAL=0

check_cluster

# Task 1: Service init-svc 존재 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get svc init-svc &>/dev/null; then
  print_pass "Task 1: Service 'init-svc' 존재"
  PASS=$((PASS+1))
else
  print_fail "Task 1: Service 'init-svc' 미존재" \
    "Service 'init-svc'를 생성하세요"
fi

# Task 2: Service port 확인
TOTAL=$((TOTAL+1))
SVC_PORT=$(kubectl -n "$NAMESPACE" get svc init-svc -o jsonpath='{.spec.ports[0].port}' 2>/dev/null)
if [ "$SVC_PORT" = "80" ]; then
  print_pass "Task 2: Service 'init-svc' port 80 설정됨"
  PASS=$((PASS+1))
else
  print_fail "Task 2: Service 'init-svc' port 불일치 (현재: $SVC_PORT)" \
    "port를 80으로 설정하세요"
fi

# Task 3: Pod Running 상태 확인
TOTAL=$((TOTAL+1))
POD_PHASE=$(kubectl -n "$NAMESPACE" get pod app-pod -o jsonpath='{.status.phase}' 2>/dev/null)
if [ "$POD_PHASE" = "Running" ]; then
  print_pass "Task 3: Pod 'app-pod' Running 상태"
  PASS=$((PASS+1))
else
  print_fail "Task 3: Pod 'app-pod' Running 아님 (현재: $POD_PHASE)" \
    "Service를 생성하면 Init Container가 완료되어 Pod가 시작됩니다"
fi

# Task 4: Init Container 완료 확인
TOTAL=$((TOTAL+1))
INIT_READY=$(kubectl -n "$NAMESPACE" get pod app-pod -o jsonpath='{.status.initContainerStatuses[0].state.terminated.reason}' 2>/dev/null)
INIT_RUNNING=$(kubectl -n "$NAMESPACE" get pod app-pod -o jsonpath='{.status.initContainerStatuses[0].ready}' 2>/dev/null)
if [ "$INIT_READY" = "Completed" ] || [ "$INIT_RUNNING" = "true" ] || [ "$POD_PHASE" = "Running" ]; then
  print_pass "Task 4: Init Container 완료됨"
  PASS=$((PASS+1))
else
  print_fail "Task 4: Init Container 미완료 (reason=$INIT_READY)" \
    "init-svc DNS가 해석 가능해야 Init Container가 완료됩니다"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
