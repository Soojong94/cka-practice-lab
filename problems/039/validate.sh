#!/bin/bash
# Problem 039: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q039"
PASS=0
TOTAL=0

check_cluster

# Task 1: Pod 존재 및 Running 확인
TOTAL=$((TOTAL+1))
POD_PHASE=$(kubectl -n "$NAMESPACE" get pod api-pod -o jsonpath='{.status.phase}' 2>/dev/null)
if [ "$POD_PHASE" = "Running" ]; then
  print_pass "Task 1: Pod 'api-pod' Running 상태"
  PASS=$((PASS+1))
else
  print_fail "Task 1: Pod 'api-pod' Running 아님 (현재: $POD_PHASE)" \
    "Pod를 재생성하세요"
fi

# Task 2: Pod spec에 automountServiceAccountToken=true 설정 확인
TOTAL=$((TOTAL+1))
AUTOMOUNT=$(kubectl -n "$NAMESPACE" get pod api-pod -o jsonpath='{.spec.automountServiceAccountToken}' 2>/dev/null)
if [ "$AUTOMOUNT" = "true" ]; then
  print_pass "Task 2: Pod spec에 automountServiceAccountToken=true 설정됨"
  PASS=$((PASS+1))
else
  print_fail "Task 2: Pod spec에 automountServiceAccountToken 미설정 또는 false (현재: $AUTOMOUNT)" \
    "Pod spec에 automountServiceAccountToken: true를 추가하세요"
fi

# Task 3: 토큰 파일 마운트 확인
TOTAL=$((TOTAL+1))
TOKEN_EXISTS=$(kubectl -n "$NAMESPACE" exec api-pod -- ls /var/run/secrets/kubernetes.io/serviceaccount/token 2>/dev/null)
if [ -n "$TOKEN_EXISTS" ]; then
  print_pass "Task 3: 토큰 파일 '/var/run/secrets/kubernetes.io/serviceaccount/token' 마운트됨"
  PASS=$((PASS+1))
else
  print_fail "Task 3: 토큰 파일 미마운트" \
    "automountServiceAccountToken: true 설정 후 Pod를 재생성하세요"
fi

# Task 4: ServiceAccount 이름 확인
TOTAL=$((TOTAL+1))
SA_NAME=$(kubectl -n "$NAMESPACE" get pod api-pod -o jsonpath='{.spec.serviceAccountName}' 2>/dev/null)
if [ "$SA_NAME" = "api-sa" ]; then
  print_pass "Task 4: Pod가 ServiceAccount 'api-sa' 사용 중"
  PASS=$((PASS+1))
else
  print_fail "Task 4: Pod의 ServiceAccount 불일치 (현재: $SA_NAME, 기대: api-sa)" \
    "serviceAccountName을 api-sa로 설정하세요"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
