#!/bin/bash
# Problem 028: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q028"
PASS=0
TOTAL=0

check_cluster

# Task 1: PVC 존재 여부
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get pvc data-pvc &>/dev/null; then
  print_pass "Task 1: PVC 'data-pvc' 존재"
  PASS=$((PASS+1))
else
  print_fail "Task 1: PVC 'data-pvc' 미존재" "PVC를 삭제하지 마세요. StorageClass를 생성하거나 PVC를 수정하세요"
fi

# Task 2: PVC Bound 상태
TOTAL=$((TOTAL+1))
PVC_STATUS=$(kubectl -n "$NAMESPACE" get pvc data-pvc -o jsonpath='{.status.phase}' 2>/dev/null)
if [ "$PVC_STATUS" = "Bound" ]; then
  print_pass "Task 2: PVC 'data-pvc' Bound 상태"
  PASS=$((PASS+1))
else
  print_fail "Task 2: PVC 'data-pvc' Bound 아님 (현재: $PVC_STATUS)" "StorageClass를 생성하거나 PVC의 storageClassName을 수정하세요"
fi

# Task 3: PVC 용량 확인
TOTAL=$((TOTAL+1))
PVC_CAPACITY=$(kubectl -n "$NAMESPACE" get pvc data-pvc -o jsonpath='{.spec.resources.requests.storage}' 2>/dev/null)
if [ "$PVC_CAPACITY" = "1Gi" ]; then
  print_pass "Task 3: PVC 용량 올바름 (1Gi)"
  PASS=$((PASS+1))
else
  print_fail "Task 3: PVC 용량 불일치 (현재: $PVC_CAPACITY)" "1Gi 용량을 유지하세요"
fi

# Task 4: StorageClass 또는 PV 존재 확인
TOTAL=$((TOTAL+1))
SC_EXISTS=$(kubectl get storageclass fast-ssd 2>/dev/null)
PV_BOUND=$(kubectl get pv -o jsonpath='{.items[?(@.spec.claimRef.name=="data-pvc")].metadata.name}' 2>/dev/null)
# hostpath StorageClass 사용 여부 확인
PVC_SC=$(kubectl -n "$NAMESPACE" get pvc data-pvc -o jsonpath='{.spec.storageClassName}' 2>/dev/null)
HOSTPATH_SC=$(kubectl get storageclass hostpath 2>/dev/null)

if [ -n "$SC_EXISTS" ] || [ -n "$PV_BOUND" ] || ([ "$PVC_SC" = "hostpath" ] && [ -n "$HOSTPATH_SC" ]); then
  print_pass "Task 4: 스토리지 프로비저닝 해결됨"
  PASS=$((PASS+1))
else
  print_fail "Task 4: 스토리지 프로비저닝 미해결" "StorageClass 'fast-ssd'를 생성하거나 PVC를 기존 StorageClass로 변경하세요"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
