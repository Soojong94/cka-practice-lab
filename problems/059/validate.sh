#!/bin/bash
# Problem 059: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q059"
PASS=0
TOTAL=0

check_cluster

# Task 1: ServiceAccount 존재 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get serviceaccount app-sa &>/dev/null; then
  print_pass "Task 1: ServiceAccount 'app-sa' 존재"
  PASS=$((PASS+1))
else
  print_fail "Task 1: ServiceAccount 'app-sa' 미생성" \
    "kubectl -n cka-q059 create serviceaccount app-sa"
fi

# Task 2: Pod가 올바른 SA 사용
TOTAL=$((TOTAL+1))
POD_SA=$(kubectl -n "$NAMESPACE" get pod app-pod -o jsonpath='{.spec.serviceAccountName}' 2>/dev/null)
if [ "$POD_SA" = "app-sa" ]; then
  print_pass "Task 2: Pod 'app-pod'가 ServiceAccount 'app-sa' 사용"
  PASS=$((PASS+1))
else
  print_fail "Task 2: Pod 'app-pod'의 ServiceAccount 불일치 (현재: '$POD_SA')" \
    "spec.serviceAccountName: app-sa 를 지정하세요"
fi

# Task 3: Pod Running 상태 확인
TOTAL=$((TOTAL+1))
POD_STATUS=$(kubectl -n "$NAMESPACE" get pod app-pod -o jsonpath='{.status.phase}' 2>/dev/null)
if [ "$POD_STATUS" = "Running" ]; then
  print_pass "Task 3: Pod 'app-pod' Running 상태"
  PASS=$((PASS+1))
else
  print_fail "Task 3: Pod 'app-pod' Running 아님 (현재: '$POD_STATUS')" \
    "Pod 상태를 확인하세요: kubectl -n cka-q059 describe pod app-pod"
fi

# Task 4: ConfigMap sa-verify의 token-status 확인
TOTAL=$((TOTAL+1))
TOKEN_STATUS=$(kubectl -n "$NAMESPACE" get configmap sa-verify -o jsonpath='{.data.token-status}' 2>/dev/null)
if [ "$TOKEN_STATUS" = "exists" ]; then
  print_pass "Task 4: ConfigMap 'sa-verify'의 token-status = exists"
  PASS=$((PASS+1))
else
  print_fail "Task 4: ConfigMap 'sa-verify'의 token-status 불일치 (현재: '$TOKEN_STATUS')" \
    "Pod 내부에서 토큰 파일 존재 여부를 확인하고 ConfigMap에 저장하세요"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
