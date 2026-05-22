#!/bin/bash
# Problem 081: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q081"
PASS=0
TOTAL=0

check_cluster

# Task 1: ClusterIP Service 'web-svc' 존재 여부 및 타입 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get svc web-svc &>/dev/null; then
  SVC_TYPE=$(kubectl -n "$NAMESPACE" get svc web-svc -o jsonpath='{.spec.type}')
  SVC_PORT=$(kubectl -n "$NAMESPACE" get svc web-svc -o jsonpath='{.spec.ports[0].port}')
  SVC_SELECTOR=$(kubectl -n "$NAMESPACE" get svc web-svc -o jsonpath='{.spec.selector.app}')
  if [ "$SVC_TYPE" = "ClusterIP" ] || [ -z "$SVC_TYPE" ]; then
    if [ "$SVC_PORT" = "80" ] && [ "$SVC_SELECTOR" = "web" ]; then
      print_pass "Task 1: Service 'web-svc' ClusterIP 타입, port=80, selector=app:web"
      PASS=$((PASS+1))
    else
      print_fail "Task 1: Service 'web-svc' 스펙 불일치 (port=$SVC_PORT, selector=$SVC_SELECTOR)" \
        "port: 80, selector: app: web 확인"
    fi
  else
    print_fail "Task 1: Service 'web-svc' 타입이 ClusterIP가 아님 (현재: $SVC_TYPE)" \
      "type: ClusterIP 확인"
  fi
else
  print_fail "Task 1: Service 'web-svc' 미생성" "kubectl expose 또는 YAML로 Service를 생성하세요"
fi

# Task 2: Endpoints 확인 (2개)
TOTAL=$((TOTAL+1))
EP_COUNT=$(kubectl -n "$NAMESPACE" get endpoints web-svc -o jsonpath='{.subsets[0].addresses}' 2>/dev/null | grep -o '"ip"' | wc -l)
if [ "$EP_COUNT" -ge 2 ] 2>/dev/null; then
  print_pass "Task 2: Service 'web-svc' Endpoints ${EP_COUNT}개 등록됨"
  PASS=$((PASS+1))
else
  print_fail "Task 2: Service 'web-svc' Endpoints 부족 (현재: ${EP_COUNT}개, 필요: 2개)" \
    "Deployment의 label과 Service의 selector가 일치하는지 확인"
fi

# Task 3: test-pod 존재 여부
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get pod test-pod &>/dev/null; then
  print_pass "Task 3: 테스트 Pod 'test-pod' 존재"
  PASS=$((PASS+1))
else
  print_fail "Task 3: 테스트 Pod 'test-pod' 미생성" \
    "curlimages/curl 이미지로 test-pod를 생성하세요"
fi

# Task 4: ConfigMap 'curl-result' 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get configmap curl-result &>/dev/null; then
  RESULT=$(kubectl -n "$NAMESPACE" get configmap curl-result -o jsonpath='{.data.result}')
  if echo "$RESULT" | grep -qi "nginx\|welcome\|html"; then
    print_pass "Task 4: ConfigMap 'curl-result'에 nginx 응답 저장됨"
    PASS=$((PASS+1))
  else
    print_fail "Task 4: ConfigMap 'curl-result' 내용이 올바르지 않음" \
      "curl 결과에 nginx 응답이 포함되어야 합니다"
  fi
else
  print_fail "Task 4: ConfigMap 'curl-result' 미생성" \
    "curl 결과를 ConfigMap에 저장하세요"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
