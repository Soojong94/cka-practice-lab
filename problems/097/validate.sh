#!/bin/bash
# Problem 097: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q097"
PASS=0
TOTAL=0

check_cluster

# Task 1: Service 'multi-port-svc' 존재 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get svc multi-port-svc &>/dev/null; then
  print_pass "Task 1: Service 'multi-port-svc' 존재"
  PASS=$((PASS+1))
else
  print_fail "Task 1: Service 'multi-port-svc' 미생성" \
    "Multi-port Service를 생성하세요"
fi

# Task 2: 포트 개수 확인 (2개)
TOTAL=$((TOTAL+1))
PORT_COUNT=$(kubectl -n "$NAMESPACE" get svc multi-port-svc -o jsonpath='{.spec.ports}' 2>/dev/null | grep -o '"port"' | wc -l)
if [ "$PORT_COUNT" -eq 2 ] 2>/dev/null; then
  print_pass "Task 2: Service에 2개 포트 정의됨"
  PASS=$((PASS+1))
else
  print_fail "Task 2: 포트 개수 불일치 (현재: ${PORT_COUNT}개, 필요: 2개)" \
    "http(80)와 https(443) 두 포트를 정의하세요"
fi

# Task 3: http 포트 (name=http, port=80) 확인
TOTAL=$((TOTAL+1))
HTTP_NAME=$(kubectl -n "$NAMESPACE" get svc multi-port-svc -o jsonpath='{.spec.ports[?(@.port==80)].name}' 2>/dev/null)
if [ "$HTTP_NAME" = "http" ]; then
  print_pass "Task 3: http 포트 (name=http, port=80) 올바름"
  PASS=$((PASS+1))
else
  print_fail "Task 3: http 포트 설정 불일치 (name=$HTTP_NAME)" \
    "ports[].name: http, ports[].port: 80 확인"
fi

# Task 4: https 포트 (name=https, port=443) 확인
TOTAL=$((TOTAL+1))
HTTPS_NAME=$(kubectl -n "$NAMESPACE" get svc multi-port-svc -o jsonpath='{.spec.ports[?(@.port==443)].name}' 2>/dev/null)
if [ "$HTTPS_NAME" = "https" ]; then
  print_pass "Task 4: https 포트 (name=https, port=443) 올바름"
  PASS=$((PASS+1))
else
  print_fail "Task 4: https 포트 설정 불일치 (name=$HTTPS_NAME)" \
    "ports[].name: https, ports[].port: 443 확인"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
