#!/bin/bash
# Problem 020: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q020"
PASS=0
TOTAL=0

check_cluster

# Task 1: NetworkPolicy 존재 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get networkpolicy deny-all-ingress &>/dev/null; then
  print_pass "Task 1: NetworkPolicy 'deny-all-ingress' 존재 확인"
  PASS=$((PASS+1))
else
  print_fail "Task 1: NetworkPolicy 'deny-all-ingress' 미존재" \
    "NetworkPolicy를 수정하여 적용하세요 (삭제하지 마세요)"
fi

# Task 2: NetworkPolicy에 ingress 규칙 존재 확인
TOTAL=$((TOTAL+1))
INGRESS_RULES=$(kubectl -n "$NAMESPACE" get networkpolicy deny-all-ingress -o jsonpath='{.spec.ingress}' 2>/dev/null)
if [ -n "$INGRESS_RULES" ] && [ "$INGRESS_RULES" != "null" ] && [ "$INGRESS_RULES" != "[]" ]; then
  print_pass "Task 2: NetworkPolicy에 ingress 규칙 존재"
  PASS=$((PASS+1))
else
  print_fail "Task 2: NetworkPolicy에 ingress 규칙 없음" \
    "client Pod에서의 트래픽을 허용하는 ingress 규칙을 추가하세요"
fi

# Task 3: ingress 규칙에 podSelector로 role=client 허용 확인
TOTAL=$((TOTAL+1))
CLIENT_SELECTOR=$(kubectl -n "$NAMESPACE" get networkpolicy deny-all-ingress -o jsonpath='{.spec.ingress[0].from[0].podSelector.matchLabels.role}' 2>/dev/null)
if [ "$CLIENT_SELECTOR" = "client" ]; then
  print_pass "Task 3: ingress 규칙에 role=client podSelector 설정됨"
  PASS=$((PASS+1))
else
  print_fail "Task 3: ingress 규칙에 role=client podSelector 미설정 (현재: $CLIENT_SELECTOR)" \
    "from.podSelector.matchLabels.role: client 를 설정하세요"
fi

# Task 4: 포트 80 허용 확인
TOTAL=$((TOTAL+1))
ALLOWED_PORT=$(kubectl -n "$NAMESPACE" get networkpolicy deny-all-ingress -o jsonpath='{.spec.ingress[0].ports[0].port}' 2>/dev/null)
if [ "$ALLOWED_PORT" = "80" ]; then
  print_pass "Task 4: 포트 80 허용 설정됨"
  PASS=$((PASS+1))
else
  print_fail "Task 4: 포트 80 허용 미설정 (현재: $ALLOWED_PORT)" \
    "ports에 port: 80, protocol: TCP를 설정하세요"
fi

# Task 5: 실제 통신 테스트 (client → server:80)
TOTAL=$((TOTAL+1))
SERVER_IP=$(kubectl -n "$NAMESPACE" get pod server -o jsonpath='{.status.podIP}' 2>/dev/null)
if [ -n "$SERVER_IP" ]; then
  CURL_RESULT=$(kubectl -n "$NAMESPACE" exec client -- curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 "http://${SERVER_IP}:80" 2>/dev/null)
  if [ "$CURL_RESULT" = "200" ]; then
    print_pass "Task 5: client → server:80 통신 성공 (HTTP 200)"
    PASS=$((PASS+1))
  else
    print_fail "Task 5: client → server:80 통신 실패 (응답: $CURL_RESULT)" \
      "NetworkPolicy 규칙이 올바르게 적용되었는지 확인하세요"
  fi
else
  print_fail "Task 5: server Pod IP를 가져올 수 없음" \
    "server Pod가 Running 상태인지 확인하세요"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
