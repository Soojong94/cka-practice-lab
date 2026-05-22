#!/bin/bash
# Problem 091: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q091"
PASS=0
TOTAL=0

check_cluster

# Task 1: Ingress 존재 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get ingress app-ingress &>/dev/null; then
  print_pass "Task 1: Ingress 'app-ingress' 존재"
  PASS=$((PASS+1))
else
  print_fail "Task 1: Ingress 'app-ingress' 미생성" \
    "Ingress 리소스를 생성하세요"
fi

# Task 2: host 설정 확인
TOTAL=$((TOTAL+1))
HOST=$(kubectl -n "$NAMESPACE" get ingress app-ingress -o jsonpath='{.spec.rules[0].host}' 2>/dev/null)
if [ "$HOST" = "app.example.com" ]; then
  print_pass "Task 2: host=app.example.com 올바름"
  PASS=$((PASS+1))
else
  print_fail "Task 2: host 불일치 (현재: $HOST)" \
    "spec.rules[].host: app.example.com 확인"
fi

# Task 3: /app1 → app1-svc 경로 확인
TOTAL=$((TOTAL+1))
INGRESS_JSON=$(kubectl -n "$NAMESPACE" get ingress app-ingress -o json 2>/dev/null)
APP1_PATH=$(echo "$INGRESS_JSON" | grep -o '"/app1"' | head -1)
APP1_SVC=$(echo "$INGRESS_JSON" | grep -o '"app1-svc"' | head -1)
if [ -n "$APP1_PATH" ] && [ -n "$APP1_SVC" ]; then
  print_pass "Task 3: /app1 → app1-svc 경로 규칙 올바름"
  PASS=$((PASS+1))
else
  print_fail "Task 3: /app1 → app1-svc 규칙 미설정" \
    "path: /app1, backend.service.name: app1-svc 확인"
fi

# Task 4: /app2 → app2-svc 경로 확인
TOTAL=$((TOTAL+1))
APP2_PATH=$(echo "$INGRESS_JSON" | grep -o '"/app2"' | head -1)
APP2_SVC=$(echo "$INGRESS_JSON" | grep -o '"app2-svc"' | head -1)
if [ -n "$APP2_PATH" ] && [ -n "$APP2_SVC" ]; then
  print_pass "Task 4: /app2 → app2-svc 경로 규칙 올바름"
  PASS=$((PASS+1))
else
  print_fail "Task 4: /app2 → app2-svc 규칙 미설정" \
    "path: /app2, backend.service.name: app2-svc 확인"
fi

# Task 5: pathType Prefix 확인
TOTAL=$((TOTAL+1))
PATH_TYPE=$(kubectl -n "$NAMESPACE" get ingress app-ingress -o jsonpath='{.spec.rules[0].http.paths[0].pathType}' 2>/dev/null)
if [ "$PATH_TYPE" = "Prefix" ]; then
  print_pass "Task 5: pathType=Prefix 올바름"
  PASS=$((PASS+1))
else
  print_fail "Task 5: pathType 불일치 (현재: $PATH_TYPE)" \
    "pathType: Prefix 확인"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
