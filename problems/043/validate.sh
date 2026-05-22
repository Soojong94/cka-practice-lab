#!/bin/bash
# Problem 043: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q043"
PASS=0
TOTAL=0

check_cluster

# Task 1: gpu-pod 존재 및 nodeAffinity 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get pod gpu-pod &>/dev/null; then
  AFFINITY_KEY=$(kubectl -n "$NAMESPACE" get pod gpu-pod -o jsonpath='{.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].key}' 2>/dev/null)
  AFFINITY_VAL=$(kubectl -n "$NAMESPACE" get pod gpu-pod -o jsonpath='{.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].values[0]}' 2>/dev/null)
  if [ "$AFFINITY_KEY" = "gpu" ] && [ "$AFFINITY_VAL" = "true" ]; then
    print_pass "Task 1: gpu-pod에 nodeAffinity (gpu=true) 올바르게 설정됨"
    PASS=$((PASS+1))
  else
    print_fail "Task 1: gpu-pod nodeAffinity 불일치 (key=$AFFINITY_KEY, value=$AFFINITY_VAL)" \
      "matchExpressions에 key: gpu, values: [\"true\"] 설정"
  fi
else
  print_fail "Task 1: Pod 'gpu-pod' 미생성" "kubectl -n $NAMESPACE run 또는 apply로 생성하세요"
fi

# Task 2: cpu-pod 존재 및 nodeAffinity 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get pod cpu-pod &>/dev/null; then
  AFFINITY_KEY=$(kubectl -n "$NAMESPACE" get pod cpu-pod -o jsonpath='{.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].key}' 2>/dev/null)
  AFFINITY_VAL=$(kubectl -n "$NAMESPACE" get pod cpu-pod -o jsonpath='{.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].values[0]}' 2>/dev/null)
  if [ "$AFFINITY_KEY" = "gpu" ] && [ "$AFFINITY_VAL" = "false" ]; then
    print_pass "Task 2: cpu-pod에 nodeAffinity (gpu=false) 올바르게 설정됨"
    PASS=$((PASS+1))
  else
    print_fail "Task 2: cpu-pod nodeAffinity 불일치 (key=$AFFINITY_KEY, value=$AFFINITY_VAL)" \
      "matchExpressions에 key: gpu, values: [\"false\"] 설정"
  fi
else
  print_fail "Task 2: Pod 'cpu-pod' 미생성" "kubectl -n $NAMESPACE run 또는 apply로 생성하세요"
fi

# Task 3: gpu-pod Running 확인
TOTAL=$((TOTAL+1))
GPU_STATUS=$(kubectl -n "$NAMESPACE" get pod gpu-pod -o jsonpath='{.status.phase}' 2>/dev/null)
if [ "$GPU_STATUS" = "Running" ]; then
  print_pass "Task 3: gpu-pod Running 상태"
  PASS=$((PASS+1))
else
  print_fail "Task 3: gpu-pod가 Running이 아님 (현재: $GPU_STATUS)" \
    "노드에 gpu=true 레이블이 있는지 확인하세요"
fi

# Task 4: cpu-pod Pending 확인
TOTAL=$((TOTAL+1))
CPU_STATUS=$(kubectl -n "$NAMESPACE" get pod cpu-pod -o jsonpath='{.status.phase}' 2>/dev/null)
if [ "$CPU_STATUS" = "Pending" ]; then
  print_pass "Task 4: cpu-pod Pending 상태 (gpu=false 노드 없음)"
  PASS=$((PASS+1))
else
  print_fail "Task 4: cpu-pod가 Pending이 아님 (현재: $CPU_STATUS)" \
    "gpu=false 레이블이 있는 노드가 없으므로 Pending이어야 합니다"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
