#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q003"
PASS=0
TOTAL=0

check_cluster

# Task 1: reclaimPolicy가 Retain인지
TOTAL=$((TOTAL+1))
RECLAIM=$(kubectl get pv cka-q003-data-pv -o jsonpath='{.spec.persistentVolumeReclaimPolicy}' 2>/dev/null)
if [ "$RECLAIM" = "Retain" ]; then
  print_pass "Task 1: PV reclaimPolicy가 'Retain'으로 변경됨"
  PASS=$((PASS+1))
else
  print_fail "Task 1: PV reclaimPolicy가 'Retain'이 아님 (현재: $RECLAIM)" \
    "kubectl patch pv cka-q003-data-pv -p '{\"spec\":{\"persistentVolumeReclaimPolicy\":\"Retain\"}}'"
fi

# Task 2: Pod 삭제 확인
TOTAL=$((TOTAL+1))
if ! kubectl -n "$NAMESPACE" get pod data-writer &>/dev/null; then
  print_pass "Task 2: Pod 'data-writer' 삭제됨"
  PASS=$((PASS+1))
else
  print_fail "Task 2: Pod 'data-writer' 아직 존재" "kubectl -n cka-q003 delete pod data-writer"
fi

# Task 3: PVC 삭제 확인
TOTAL=$((TOTAL+1))
if ! kubectl -n "$NAMESPACE" get pvc data-pvc &>/dev/null; then
  print_pass "Task 3: PVC 'data-pvc' 삭제됨"
  PASS=$((PASS+1))
else
  print_fail "Task 3: PVC 'data-pvc' 아직 존재" "Pod를 먼저 삭제한 후 PVC를 삭제하세요"
fi

# Task 4: PV가 Released 상태인지
TOTAL=$((TOTAL+1))
PV_STATUS=$(kubectl get pv cka-q003-data-pv -o jsonpath='{.status.phase}' 2>/dev/null)
if [ "$PV_STATUS" = "Released" ]; then
  print_pass "Task 4: PV 'cka-q003-data-pv' Released 상태 (데이터 보존됨)"
  PASS=$((PASS+1))
else
  print_fail "Task 4: PV 상태가 Released가 아님 (현재: $PV_STATUS)" \
    "reclaimPolicy를 Retain으로 변경한 후 PVC를 삭제해야 합니다"
fi

print_score $PASS $TOTAL
[ $PASS -eq $TOTAL ] && exit 0 || exit 1
