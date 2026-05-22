#!/bin/bash
# Problem 009: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q009"
PASS=0
TOTAL=0

check_cluster

# Task 1: Pod 'projected-pod' Running 상태 확인
TOTAL=$((TOTAL+1))
POD_STATUS=$(kubectl -n "$NAMESPACE" get pod projected-pod -o jsonpath='{.status.phase}' 2>/dev/null)
if [ "$POD_STATUS" = "Running" ]; then
  print_pass "Task 1: Pod 'projected-pod' Running 상태"
  PASS=$((PASS+1))
else
  print_fail "Task 1: Pod 'projected-pod' Running 아님 (현재: $POD_STATUS)" \
    "Pod를 생성하고 Running 상태인지 확인하세요"
fi

# Task 2: ServiceAccount 'app-sa' 사용 확인
TOTAL=$((TOTAL+1))
SA_NAME=$(kubectl -n "$NAMESPACE" get pod projected-pod -o jsonpath='{.spec.serviceAccountName}' 2>/dev/null)
if [ "$SA_NAME" = "app-sa" ]; then
  print_pass "Task 2: Pod가 ServiceAccount 'app-sa' 사용"
  PASS=$((PASS+1))
else
  print_fail "Task 2: Pod의 ServiceAccount 불일치 (현재: $SA_NAME)" \
    "spec.serviceAccountName: app-sa를 설정하세요"
fi

# Task 3: projected 볼륨에서 ServiceAccount 토큰 확인
TOTAL=$((TOTAL+1))
TOKEN_EXISTS=$(kubectl -n "$NAMESPACE" exec projected-pod -- cat /etc/projected/token 2>/dev/null)
if [ -n "$TOKEN_EXISTS" ]; then
  print_pass "Task 3: /etc/projected/token 파일 존재 (ServiceAccount 토큰)"
  PASS=$((PASS+1))
else
  print_fail "Task 3: /etc/projected/token 파일 없음" \
    "projected 볼륨에 serviceAccountToken 소스를 추가하세요"
fi

# Task 4: projected 볼륨에서 ConfigMap 확인
TOTAL=$((TOTAL+1))
CONFIG_CONTENT=$(kubectl -n "$NAMESPACE" exec projected-pod -- cat /etc/projected/config/app.properties 2>/dev/null)
if echo "$CONFIG_CONTENT" | grep -q "app.name=projected-demo"; then
  print_pass "Task 4: /etc/projected/config/app.properties 파일 확인 (ConfigMap 내용)"
  PASS=$((PASS+1))
else
  print_fail "Task 4: /etc/projected/config/app.properties 파일 없거나 내용 불일치" \
    "projected 볼륨에 configMap 소스를 추가하세요 (items로 path 지정)"
fi

# Task 5: projected 볼륨에서 Secret 확인
TOTAL=$((TOTAL+1))
SECRET_CONTENT=$(kubectl -n "$NAMESPACE" exec projected-pod -- cat /etc/projected/secrets/api-key 2>/dev/null)
if [ "$SECRET_CONTENT" = "k8s-projected-secret-key-2024" ]; then
  print_pass "Task 5: /etc/projected/secrets/api-key 파일 확인 (Secret 내용)"
  PASS=$((PASS+1))
else
  print_fail "Task 5: /etc/projected/secrets/api-key 파일 없거나 내용 불일치 (내용: $SECRET_CONTENT)" \
    "projected 볼륨에 secret 소스를 추가하세요 (items로 path 지정)"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
