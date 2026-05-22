#!/bin/bash
# Problem 047: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q047"
PASS=0
TOTAL=0

check_cluster

# Task 1: HPA 존재 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get hpa hpa-target &>/dev/null; then
  print_pass "Task 1: HPA 'hpa-target' 존재"
  PASS=$((PASS+1))
else
  print_fail "Task 1: HPA 'hpa-target' 미생성" \
    "kubectl -n $NAMESPACE autoscale deployment hpa-target --min=2 --max=5 --cpu-percent=50"
fi

# Task 2: HPA 설정 확인 (min, max, target)
TOTAL=$((TOTAL+1))
MIN_REPLICAS=$(kubectl -n "$NAMESPACE" get hpa hpa-target -o jsonpath='{.spec.minReplicas}' 2>/dev/null)
MAX_REPLICAS=$(kubectl -n "$NAMESPACE" get hpa hpa-target -o jsonpath='{.spec.maxReplicas}' 2>/dev/null)
TARGET_CPU=$(kubectl -n "$NAMESPACE" get hpa hpa-target -o jsonpath='{.spec.metrics[0].resource.target.averageUtilization}' 2>/dev/null)
# v1 API 호환
if [ -z "$TARGET_CPU" ]; then
  TARGET_CPU=$(kubectl -n "$NAMESPACE" get hpa hpa-target -o jsonpath='{.spec.targetCPUUtilizationPercentage}' 2>/dev/null)
fi
if [ "$MIN_REPLICAS" = "2" ] && [ "$MAX_REPLICAS" = "5" ] && [ "$TARGET_CPU" = "50" ]; then
  print_pass "Task 2: HPA 설정 올바름 (min=2, max=5, targetCPU=50%)"
  PASS=$((PASS+1))
else
  print_fail "Task 2: HPA 설정 불일치 (min=$MIN_REPLICAS, max=$MAX_REPLICAS, targetCPU=$TARGET_CPU)" \
    "min=2, max=5, cpu-percent=50 확인"
fi

# Task 3: Deployment 최소 2 replicas 확인
TOTAL=$((TOTAL+1))
REPLICAS=$(kubectl -n "$NAMESPACE" get deployment hpa-target -o jsonpath='{.spec.replicas}' 2>/dev/null)
if [ -n "$REPLICAS" ] && [ "$REPLICAS" -ge 2 ]; then
  print_pass "Task 3: Deployment 최소 2 replicas로 스케일됨 (현재: $REPLICAS)"
  PASS=$((PASS+1))
else
  print_fail "Task 3: Deployment replicas 부족 (현재: $REPLICAS)" \
    "HPA가 minReplicas=2로 설정되면 자동으로 스케일됩니다"
fi

# Task 4: HPA 대상 리소스 확인
TOTAL=$((TOTAL+1))
HPA_REF=$(kubectl -n "$NAMESPACE" get hpa hpa-target -o jsonpath='{.spec.scaleTargetRef.name}' 2>/dev/null)
if [ "$HPA_REF" = "hpa-target" ]; then
  print_pass "Task 4: HPA가 Deployment 'hpa-target'을 대상으로 설정됨"
  PASS=$((PASS+1))
else
  print_fail "Task 4: HPA 대상 불일치 (현재: $HPA_REF)" \
    "scaleTargetRef가 deployment hpa-target을 가리켜야 합니다"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
