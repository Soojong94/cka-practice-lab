#!/bin/bash
# Problem 060: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q060"
PASS=0
TOTAL=0

check_cluster

# Task 1: Pod 존재 및 SA 확인
TOTAL=$((TOTAL+1))
POD_SA=$(kubectl -n "$NAMESPACE" get pod api-pod -o jsonpath='{.spec.serviceAccountName}' 2>/dev/null)
if [ "$POD_SA" = "api-reader" ]; then
  print_pass "Task 1: Pod 'api-pod'가 ServiceAccount 'api-reader' 사용"
  PASS=$((PASS+1))
else
  print_fail "Task 1: Pod 'api-pod'의 ServiceAccount 불일치 (현재: '$POD_SA')" \
    "spec.serviceAccountName: api-reader 를 지정하세요"
fi

# Task 2: Pod Running 상태
TOTAL=$((TOTAL+1))
POD_STATUS=$(kubectl -n "$NAMESPACE" get pod api-pod -o jsonpath='{.status.phase}' 2>/dev/null)
if [ "$POD_STATUS" = "Running" ]; then
  print_pass "Task 2: Pod 'api-pod' Running 상태"
  PASS=$((PASS+1))
else
  print_fail "Task 2: Pod 'api-pod' Running 아님 (현재: '$POD_STATUS')" \
    "Pod 상태를 확인하세요"
fi

# Task 3: ConfigMap api-result의 secret-names 확인
TOTAL=$((TOTAL+1))
SECRET_NAMES=$(kubectl -n "$NAMESPACE" get configmap api-result -o jsonpath='{.data.secret-names}' 2>/dev/null)
if echo "$SECRET_NAMES" | grep -q "test-secret"; then
  print_pass "Task 3: ConfigMap 'api-result'의 secret-names에 test-secret 포함"
  PASS=$((PASS+1))
else
  print_fail "Task 3: ConfigMap 'api-result'의 secret-names에 test-secret 미포함 (현재: '$SECRET_NAMES')" \
    "API 응답에서 secret 이름을 추출하세요"
fi

# Task 4: response-code 확인
TOTAL=$((TOTAL+1))
RESPONSE_CODE=$(kubectl -n "$NAMESPACE" get configmap api-result -o jsonpath='{.data.response-code}' 2>/dev/null)
if [ "$RESPONSE_CODE" = "200" ]; then
  print_pass "Task 4: response-code = 200"
  PASS=$((PASS+1))
else
  print_fail "Task 4: response-code 불일치 (현재: '$RESPONSE_CODE')" \
    "curl -w '%{http_code}' 옵션으로 응답 코드를 확인하세요"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
