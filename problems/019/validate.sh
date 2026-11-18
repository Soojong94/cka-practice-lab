#!/bin/bash
# Problem 019: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q019"
PASS=0
TOTAL=0

check_cluster

# Task 1: Service web-svc 존재 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get svc web-svc &>/dev/null; then
  print_pass "Task 1: Service 'web-svc' 존재 확인"
  PASS=$((PASS+1))
else
  print_fail "Task 1: Service 'web-svc' 미존재" "Service를 확인하세요"
fi

# Task 2: Service selector가 올바른지 확인
TOTAL=$((TOTAL+1))
SELECTOR=$(kubectl -n "$NAMESPACE" get svc web-svc -o jsonpath='{.spec.selector.app}' 2>/dev/null)
if [ "$SELECTOR" = "web" ]; then
  print_pass "Task 2: Service selector 올바름 (app=web)"
  PASS=$((PASS+1))
else
  print_fail "Task 2: Service selector 불일치 (현재: app=$SELECTOR)" \
    "selector를 app=web으로 수정하세요"
fi

# Task 3: Endpoints 존재 확인
TOTAL=$((TOTAL+1))
ENDPOINTS=$(kubectl -n "$NAMESPACE" get endpoints web-svc -o jsonpath='{.subsets[0].addresses}' 2>/dev/null)
if [ -n "$ENDPOINTS" ] && [ "$ENDPOINTS" != "null" ]; then
  print_pass "Task 3: Service 'web-svc'에 Endpoints 존재"
  PASS=$((PASS+1))
else
  print_fail "Task 3: Service 'web-svc'에 Endpoints 없음" \
    "Service selector와 Pod 라벨이 일치하는지 확인하세요"
fi

# Task 4: Service를 통한 접근 테스트
TOTAL=$((TOTAL+1))
SVC_IP=$(kubectl -n "$NAMESPACE" get svc web-svc -o jsonpath='{.spec.clusterIP}' 2>/dev/null)
CURL_RESULT=$(run_in_pod "$NAMESPACE" curl-test curlimages/curl:8.4.0 curl -s -m 10 -o /dev/null -w "%{http_code}" "http://${SVC_IP}:80")
if echo "$CURL_RESULT" | grep -q "200"; then
  print_pass "Task 4: Service를 통한 접근 성공 (HTTP 200)"
  PASS=$((PASS+1))
else
  print_fail "Task 4: Service를 통한 접근 실패" \
    "Service의 Endpoints와 Pod 상태를 확인하세요"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
