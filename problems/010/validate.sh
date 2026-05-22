#!/bin/bash
# Problem 010: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q010"
PASS=0
TOTAL=0

check_cluster

# Task 1: PV 'debug-pv' 존재 확인
TOTAL=$((TOTAL+1))
if kubectl get pv debug-pv &>/dev/null; then
  PV_SC=$(kubectl get pv debug-pv -o jsonpath='{.spec.storageClassName}')
  PV_ACCESS=$(kubectl get pv debug-pv -o jsonpath='{.spec.accessModes[0]}')
  PV_CAPACITY=$(kubectl get pv debug-pv -o jsonpath='{.spec.capacity.storage}')
  print_pass "Task 1: PV 'debug-pv' 존재 (sc=$PV_SC, access=$PV_ACCESS, capacity=$PV_CAPACITY)"
  PASS=$((PASS+1))
else
  print_fail "Task 1: PV 'debug-pv' 미존재" "PV가 삭제되었는지 확인하세요"
fi

# Task 2: PVC 'debug-pvc' storageClassName이 PV와 일치하는지 확인
TOTAL=$((TOTAL+1))
PVC_SC=$(kubectl -n "$NAMESPACE" get pvc debug-pvc -o jsonpath='{.spec.storageClassName}' 2>/dev/null)
PV_SC=$(kubectl get pv debug-pv -o jsonpath='{.spec.storageClassName}' 2>/dev/null)
if [ "$PVC_SC" = "$PV_SC" ]; then
  print_pass "Task 2: PVC storageClassName이 PV와 일치 ($PVC_SC)"
  PASS=$((PASS+1))
else
  print_fail "Task 2: PVC storageClassName 불일치 (PVC=$PVC_SC, PV=$PV_SC)" \
    "PVC의 storageClassName을 PV와 동일하게 수정하세요"
fi

# Task 3: PVC accessModes가 PV와 일치하는지 확인
TOTAL=$((TOTAL+1))
PVC_ACCESS=$(kubectl -n "$NAMESPACE" get pvc debug-pvc -o jsonpath='{.spec.accessModes[0]}' 2>/dev/null)
PV_ACCESS=$(kubectl get pv debug-pv -o jsonpath='{.spec.accessModes[0]}' 2>/dev/null)
if [ "$PVC_ACCESS" = "$PV_ACCESS" ]; then
  print_pass "Task 3: PVC accessModes가 PV와 일치 ($PVC_ACCESS)"
  PASS=$((PASS+1))
else
  print_fail "Task 3: PVC accessModes 불일치 (PVC=$PVC_ACCESS, PV=$PV_ACCESS)" \
    "PVC의 accessModes를 PV와 동일하게 수정하세요"
fi

# Task 4: PVC가 Bound 상태인지 확인
TOTAL=$((TOTAL+1))
PVC_STATUS=$(kubectl -n "$NAMESPACE" get pvc debug-pvc -o jsonpath='{.status.phase}' 2>/dev/null)
if [ "$PVC_STATUS" = "Bound" ]; then
  print_pass "Task 4: PVC 'debug-pvc' Bound 상태"
  PASS=$((PASS+1))
else
  print_fail "Task 4: PVC 'debug-pvc' Bound 아님 (현재: $PVC_STATUS)" \
    "storageClassName과 accessModes를 모두 수정한 후 PVC를 재생성하세요"
fi

# Task 5: PVC가 PV 'debug-pv'에 바인딩되었는지 확인
TOTAL=$((TOTAL+1))
BOUND_PV=$(kubectl -n "$NAMESPACE" get pvc debug-pvc -o jsonpath='{.spec.volumeName}' 2>/dev/null)
if [ "$BOUND_PV" = "debug-pv" ]; then
  print_pass "Task 5: PVC 'debug-pvc'가 PV 'debug-pv'에 바인딩됨"
  PASS=$((PASS+1))
else
  print_fail "Task 5: PVC가 PV 'debug-pv'에 바인딩되지 않음 (현재 volumeName: $BOUND_PV)" \
    "PVC가 올바른 PV에 바인딩되었는지 확인하세요"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
