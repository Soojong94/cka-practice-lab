#!/bin/bash
# Problem 065: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q065"
PASS=0
TOTAL=0

check_cluster

# Task 1: crd-exists 확인
TOTAL=$((TOTAL+1))
CRD_EXISTS=$(kubectl -n "$NAMESPACE" get configmap operator-verify -o jsonpath='{.data.crd-exists}' 2>/dev/null)
if [ "$CRD_EXISTS" = "true" ]; then
  print_pass "Task 1: crd-exists = true"
  PASS=$((PASS+1))
else
  print_fail "Task 1: crd-exists 불일치 (현재: '$CRD_EXISTS')" \
    "kubectl get crd apps.operator.example.com 으로 확인 후 ConfigMap에 저장"
fi

# Task 2: Custom Resource 존재 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get apps.operator.example.com my-app &>/dev/null; then
  APP_NAME=$(kubectl -n "$NAMESPACE" get apps.operator.example.com my-app -o jsonpath='{.spec.appName}' 2>/dev/null)
  APP_REPLICAS=$(kubectl -n "$NAMESPACE" get apps.operator.example.com my-app -o jsonpath='{.spec.replicas}' 2>/dev/null)
  APP_IMAGE=$(kubectl -n "$NAMESPACE" get apps.operator.example.com my-app -o jsonpath='{.spec.image}' 2>/dev/null)
  if [ "$APP_NAME" = "web-frontend" ] && [ "$APP_REPLICAS" = "2" ] && [ "$APP_IMAGE" = "nginx:alpine" ]; then
    print_pass "Task 2: CR 'my-app' 올바르게 생성됨"
    PASS=$((PASS+1))
  else
    print_fail "Task 2: CR 'my-app' spec 불일치 (appName: $APP_NAME, replicas: $APP_REPLICAS, image: $APP_IMAGE)" \
      "appName: web-frontend, replicas: 2, image: nginx:alpine"
  fi
else
  print_fail "Task 2: CR 'my-app' 미생성" \
    "apiVersion: operator.example.com/v1, kind: App으로 CR을 생성하세요"
fi

# Task 3: controller-running 확인
TOTAL=$((TOTAL+1))
CTRL_RUNNING=$(kubectl -n "$NAMESPACE" get configmap operator-verify -o jsonpath='{.data.controller-running}' 2>/dev/null)
if [ "$CTRL_RUNNING" = "true" ]; then
  print_pass "Task 3: controller-running = true"
  PASS=$((PASS+1))
else
  print_fail "Task 3: controller-running 불일치 (현재: '$CTRL_RUNNING')" \
    "kubectl -n cka-q065 get deployment app-controller 상태를 확인하세요"
fi

# Task 4: cr-detected 확인
TOTAL=$((TOTAL+1))
CR_DETECTED=$(kubectl -n "$NAMESPACE" get configmap operator-verify -o jsonpath='{.data.cr-detected}' 2>/dev/null)
if [ "$CR_DETECTED" = "true" ]; then
  print_pass "Task 4: cr-detected = true"
  PASS=$((PASS+1))
else
  print_fail "Task 4: cr-detected 불일치 (현재: '$CR_DETECTED')" \
    "kubectl -n cka-q065 logs deployment/app-controller | grep my-app"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
