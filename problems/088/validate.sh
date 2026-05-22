#!/bin/bash
# Problem 088: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q088"
PASS=0
TOTAL=0

check_cluster

# Task 1: GatewayClass 'example-gc' 존재 확인
TOTAL=$((TOTAL+1))
if kubectl get gatewayclass example-gc &>/dev/null; then
  CONTROLLER=$(kubectl get gatewayclass example-gc -o jsonpath='{.spec.controllerName}' 2>/dev/null)
  if [ "$CONTROLLER" = "example.com/gateway-controller" ]; then
    print_pass "Task 1: GatewayClass 'example-gc' 올바름 (controller=$CONTROLLER)"
    PASS=$((PASS+1))
  else
    print_fail "Task 1: GatewayClass controllerName 불일치 (현재: $CONTROLLER)" \
      "spec.controllerName: example.com/gateway-controller 확인"
  fi
else
  print_fail "Task 1: GatewayClass 'example-gc' 미생성" \
    "GatewayClass 리소스를 생성하세요"
fi

# Task 2: Gateway 'main-gateway' 존재 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get gateway main-gateway &>/dev/null; then
  GW_CLASS=$(kubectl -n "$NAMESPACE" get gateway main-gateway -o jsonpath='{.spec.gatewayClassName}' 2>/dev/null)
  if [ "$GW_CLASS" = "example-gc" ]; then
    print_pass "Task 2: Gateway 'main-gateway' gatewayClassName=example-gc 올바름"
    PASS=$((PASS+1))
  else
    print_fail "Task 2: Gateway gatewayClassName 불일치 (현재: $GW_CLASS)" \
      "spec.gatewayClassName: example-gc 확인"
  fi
else
  print_fail "Task 2: Gateway 'main-gateway' 미생성" \
    "Gateway 리소스를 생성하세요"
fi

# Task 3: Gateway listener 설정 확인 (HTTP, port 80)
TOTAL=$((TOTAL+1))
LISTENER_PROTOCOL=$(kubectl -n "$NAMESPACE" get gateway main-gateway -o jsonpath='{.spec.listeners[0].protocol}' 2>/dev/null)
LISTENER_PORT=$(kubectl -n "$NAMESPACE" get gateway main-gateway -o jsonpath='{.spec.listeners[0].port}' 2>/dev/null)
if [ "$LISTENER_PROTOCOL" = "HTTP" ] && [ "$LISTENER_PORT" = "80" ]; then
  print_pass "Task 3: Gateway listener 올바름 (protocol=HTTP, port=80)"
  PASS=$((PASS+1))
else
  print_fail "Task 3: Gateway listener 불일치 (protocol=$LISTENER_PROTOCOL, port=$LISTENER_PORT)" \
    "listeners[].protocol: HTTP, listeners[].port: 80 확인"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
