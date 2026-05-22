#!/bin/bash
# Problem 093: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q093"
PASS=0
TOTAL=0

check_cluster

# Task 1: Service 'external-db' 존재 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get svc external-db &>/dev/null; then
  print_pass "Task 1: Service 'external-db' 존재"
  PASS=$((PASS+1))
else
  print_fail "Task 1: Service 'external-db' 미생성" \
    "ExternalName Service를 생성하세요"
fi

# Task 2: Service 타입 ExternalName 확인
TOTAL=$((TOTAL+1))
SVC_TYPE=$(kubectl -n "$NAMESPACE" get svc external-db -o jsonpath='{.spec.type}' 2>/dev/null)
if [ "$SVC_TYPE" = "ExternalName" ]; then
  print_pass "Task 2: Service 타입=ExternalName 올바름"
  PASS=$((PASS+1))
else
  print_fail "Task 2: Service 타입 불일치 (현재: $SVC_TYPE)" \
    "spec.type: ExternalName 확인"
fi

# Task 3: externalName 값 확인
TOTAL=$((TOTAL+1))
EXT_NAME=$(kubectl -n "$NAMESPACE" get svc external-db -o jsonpath='{.spec.externalName}' 2>/dev/null)
if [ "$EXT_NAME" = "db.external-company.com" ]; then
  print_pass "Task 3: externalName=db.external-company.com 올바름"
  PASS=$((PASS+1))
else
  print_fail "Task 3: externalName 불일치 (현재: $EXT_NAME)" \
    "spec.externalName: db.external-company.com 확인"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
