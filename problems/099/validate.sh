#!/bin/bash
# Problem 099: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q099"
PASS=0
TOTAL=0

check_cluster

# Task 1: livenessProbe 확인
TOTAL=$((TOTAL+1))
LIVENESS_PATH=$(kubectl -n "$NAMESPACE" get deployment probe-app -o jsonpath='{.spec.template.spec.containers[0].livenessProbe.httpGet.path}' 2>/dev/null)
LIVENESS_PORT=$(kubectl -n "$NAMESPACE" get deployment probe-app -o jsonpath='{.spec.template.spec.containers[0].livenessProbe.httpGet.port}' 2>/dev/null)
LIVENESS_PERIOD=$(kubectl -n "$NAMESPACE" get deployment probe-app -o jsonpath='{.spec.template.spec.containers[0].livenessProbe.periodSeconds}' 2>/dev/null)
if [ "$LIVENESS_PATH" = "/healthz" ] && [ "$LIVENESS_PORT" = "80" ] && [ "$LIVENESS_PERIOD" = "10" ]; then
  print_pass "Task 1: livenessProbe 올바름 (httpGet /healthz:80, period=10s)"
  PASS=$((PASS+1))
else
  print_fail "Task 1: livenessProbe 불일치 (path=$LIVENESS_PATH, port=$LIVENESS_PORT, period=$LIVENESS_PERIOD)" \
    "httpGet path=/healthz, port=80, periodSeconds=10 확인"
fi

# Task 2: readinessProbe 확인
TOTAL=$((TOTAL+1))
READINESS_PATH=$(kubectl -n "$NAMESPACE" get deployment probe-app -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.httpGet.path}' 2>/dev/null)
READINESS_PORT=$(kubectl -n "$NAMESPACE" get deployment probe-app -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.httpGet.port}' 2>/dev/null)
READINESS_DELAY=$(kubectl -n "$NAMESPACE" get deployment probe-app -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.initialDelaySeconds}' 2>/dev/null)
if [ "$READINESS_PATH" = "/" ] && [ "$READINESS_PORT" = "80" ] && [ "$READINESS_DELAY" = "5" ]; then
  print_pass "Task 2: readinessProbe 올바름 (httpGet /:80, initialDelay=5s)"
  PASS=$((PASS+1))
else
  print_fail "Task 2: readinessProbe 불일치 (path=$READINESS_PATH, port=$READINESS_PORT, delay=$READINESS_DELAY)" \
    "httpGet path=/, port=80, initialDelaySeconds=5 확인"
fi

# Task 3: startupProbe 확인
TOTAL=$((TOTAL+1))
STARTUP_PATH=$(kubectl -n "$NAMESPACE" get deployment probe-app -o jsonpath='{.spec.template.spec.containers[0].startupProbe.httpGet.path}' 2>/dev/null)
STARTUP_PORT=$(kubectl -n "$NAMESPACE" get deployment probe-app -o jsonpath='{.spec.template.spec.containers[0].startupProbe.httpGet.port}' 2>/dev/null)
STARTUP_THRESHOLD=$(kubectl -n "$NAMESPACE" get deployment probe-app -o jsonpath='{.spec.template.spec.containers[0].startupProbe.failureThreshold}' 2>/dev/null)
STARTUP_PERIOD=$(kubectl -n "$NAMESPACE" get deployment probe-app -o jsonpath='{.spec.template.spec.containers[0].startupProbe.periodSeconds}' 2>/dev/null)
if [ "$STARTUP_PATH" = "/" ] && [ "$STARTUP_PORT" = "80" ] && [ "$STARTUP_THRESHOLD" = "30" ] && [ "$STARTUP_PERIOD" = "10" ]; then
  print_pass "Task 3: startupProbe 올바름 (httpGet /:80, failureThreshold=30, period=10s)"
  PASS=$((PASS+1))
else
  print_fail "Task 3: startupProbe 불일치 (path=$STARTUP_PATH, port=$STARTUP_PORT, threshold=$STARTUP_THRESHOLD, period=$STARTUP_PERIOD)" \
    "httpGet path=/, port=80, failureThreshold=30, periodSeconds=10 확인"
fi

# Task 4: Pod Running 상태 확인
TOTAL=$((TOTAL+1))
READY_PODS=$(kubectl -n "$NAMESPACE" get deployment probe-app -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
if [ "$READY_PODS" = "1" ]; then
  print_pass "Task 4: Pod Running 및 Ready 상태"
  PASS=$((PASS+1))
else
  print_fail "Task 4: Pod Ready 아님 (readyReplicas=$READY_PODS)" \
    "Probe 설정 후 Pod가 정상 시작되는지 확인"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
