#!/bin/bash
# Problem 082: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q082"
PASS=0
TOTAL=0

check_cluster

# Task 1: NodePort Service 'api-nodeport' 존재 및 타입 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get svc api-nodeport &>/dev/null; then
  SVC_TYPE=$(kubectl -n "$NAMESPACE" get svc api-nodeport -o jsonpath='{.spec.type}')
  if [ "$SVC_TYPE" = "NodePort" ]; then
    print_pass "Task 1: Service 'api-nodeport' NodePort 타입 확인"
    PASS=$((PASS+1))
  else
    print_fail "Task 1: Service 'api-nodeport' 타입이 NodePort가 아님 (현재: $SVC_TYPE)" \
      "spec.type: NodePort 확인"
  fi
else
  print_fail "Task 1: Service 'api-nodeport' 미생성" "NodePort Service를 생성하세요"
fi

# Task 2: nodePort=30080 확인
TOTAL=$((TOTAL+1))
NODE_PORT=$(kubectl -n "$NAMESPACE" get svc api-nodeport -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null)
if [ "$NODE_PORT" = "30080" ]; then
  print_pass "Task 2: nodePort=30080 올바르게 설정됨"
  PASS=$((PASS+1))
else
  print_fail "Task 2: nodePort 값 불일치 (현재: $NODE_PORT, 필요: 30080)" \
    "spec.ports[].nodePort: 30080 확인"
fi

# Task 3: Endpoints 존재 확인
TOTAL=$((TOTAL+1))
EP_COUNT=$(kubectl -n "$NAMESPACE" get endpoints api-nodeport -o jsonpath='{.subsets[0].addresses}' 2>/dev/null | grep -o '"ip"' | wc -l)
if [ "$EP_COUNT" -ge 1 ] 2>/dev/null; then
  print_pass "Task 3: Service 'api-nodeport' Endpoints ${EP_COUNT}개 등록됨"
  PASS=$((PASS+1))
else
  print_fail "Task 3: Service 'api-nodeport' Endpoints 없음" \
    "selector가 Deployment의 label과 일치하는지 확인"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
