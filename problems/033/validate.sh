#!/bin/bash
# Problem 033: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q033"
PASS=0
TOTAL=0

check_cluster

# Task 1: Ingress 존재 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get ingress web-ingress &>/dev/null; then
  print_pass "Task 1: Ingress 'web-ingress' 존재"
  PASS=$((PASS+1))
else
  print_fail "Task 1: Ingress 'web-ingress' 미존재" \
    "Ingress를 삭제하지 마세요"
fi

# Task 2: pathType이 Prefix인지 확인
TOTAL=$((TOTAL+1))
PATH_TYPE=$(kubectl -n "$NAMESPACE" get ingress web-ingress -o jsonpath='{.spec.rules[0].http.paths[0].pathType}' 2>/dev/null)
if [ "$PATH_TYPE" = "Prefix" ]; then
  print_pass "Task 2: pathType 'Prefix' 올바르게 설정됨"
  PASS=$((PASS+1))
else
  print_fail "Task 2: pathType 불일치 (현재: $PATH_TYPE, 기대: Prefix)" \
    "pathType을 Prefix로 변경하세요"
fi

# Task 3: backend service port가 80인지 확인
TOTAL=$((TOTAL+1))
SVC_PORT=$(kubectl -n "$NAMESPACE" get ingress web-ingress -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.port.number}' 2>/dev/null)
if [ "$SVC_PORT" = "80" ]; then
  print_pass "Task 3: backend service port '80' 올바르게 설정됨"
  PASS=$((PASS+1))
else
  print_fail "Task 3: backend service port 불일치 (현재: $SVC_PORT, 기대: 80)" \
    "backend.service.port.number를 80으로 수정하세요"
fi

# Task 4: backend service name이 web-svc인지 확인
TOTAL=$((TOTAL+1))
SVC_NAME=$(kubectl -n "$NAMESPACE" get ingress web-ingress -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}' 2>/dev/null)
if [ "$SVC_NAME" = "web-svc" ]; then
  print_pass "Task 4: backend service name 'web-svc' 올바르게 설정됨"
  PASS=$((PASS+1))
else
  print_fail "Task 4: backend service name 불일치 (현재: $SVC_NAME, 기대: web-svc)" \
    "backend.service.name을 web-svc로 설정하세요"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
