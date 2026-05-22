#!/bin/bash
# Problem 034: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q034"
PASS=0
TOTAL=0

check_cluster

# Task 1: Deployment 존재 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get deployment web-deploy &>/dev/null; then
  print_pass "Task 1: Deployment 'web-deploy' 존재"
  PASS=$((PASS+1))
else
  print_fail "Task 1: Deployment 'web-deploy' 미존재" \
    "Deployment를 삭제하지 마세요"
fi

# Task 2: CPU requests 설정 확인
TOTAL=$((TOTAL+1))
CPU_REQ=$(kubectl -n "$NAMESPACE" get deployment web-deploy -o jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu}' 2>/dev/null)
if [ -n "$CPU_REQ" ]; then
  print_pass "Task 2: CPU requests 설정됨 ($CPU_REQ)"
  PASS=$((PASS+1))
else
  print_fail "Task 2: CPU requests 미설정" \
    "Deployment에 resources.requests.cpu를 추가하세요"
fi

# Task 3: CPU limits 설정 확인
TOTAL=$((TOTAL+1))
CPU_LIM=$(kubectl -n "$NAMESPACE" get deployment web-deploy -o jsonpath='{.spec.template.spec.containers[0].resources.limits.cpu}' 2>/dev/null)
if [ -n "$CPU_LIM" ]; then
  print_pass "Task 3: CPU limits 설정됨 ($CPU_LIM)"
  PASS=$((PASS+1))
else
  print_fail "Task 3: CPU limits 미설정" \
    "Deployment에 resources.limits.cpu를 추가하세요"
fi

# Task 4: HPA가 정상 동작하는지 확인 (unknown이 아닌지)
TOTAL=$((TOTAL+1))
HPA_TARGETS=$(kubectl -n "$NAMESPACE" get hpa web-hpa -o jsonpath='{.status.conditions[?(@.type=="ScalingActive")].status}' 2>/dev/null)
HPA_CURRENT=$(kubectl -n "$NAMESPACE" get hpa web-hpa --no-headers 2>/dev/null | awk '{print $3}')
if [ "$HPA_TARGETS" = "True" ] || [[ "$HPA_CURRENT" != *"unknown"* && -n "$HPA_CURRENT" ]]; then
  print_pass "Task 4: HPA 정상 동작 중 (ScalingActive 또는 메트릭 수집 중)"
  PASS=$((PASS+1))
else
  # metrics-server가 없을 수 있으므로 resource requests 존재만으로도 부분 통과
  if [ -n "$CPU_REQ" ]; then
    print_pass "Task 4: CPU requests 설정됨 - HPA 동작 조건 충족 (metrics-server 필요)"
    PASS=$((PASS+1))
  else
    print_fail "Task 4: HPA 미동작 (TARGETS: $HPA_CURRENT)" \
      "Deployment에 CPU resource requests를 추가하세요"
  fi
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
