#!/bin/bash
# Problem 004: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q004"
PASS=0
TOTAL=0

check_cluster

# Task 1: StorageClass에 allowVolumeExpansion 설정 확인
TOTAL=$((TOTAL+1))
EXPANSION=$(kubectl get storageclass expandable-sc -o jsonpath='{.allowVolumeExpansion}' 2>/dev/null)
if [ "$EXPANSION" = "true" ]; then
  print_pass "Task 1: StorageClass 'expandable-sc'에 allowVolumeExpansion=true 설정됨"
  PASS=$((PASS+1))
else
  print_fail "Task 1: StorageClass 'expandable-sc'에 allowVolumeExpansion 미설정" \
    "kubectl get sc expandable-sc -o yaml로 확인하세요"
fi

# Task 2: PVC spec의 요청 용량이 2Gi인지 확인
TOTAL=$((TOTAL+1))
PVC_REQUEST=$(kubectl -n "$NAMESPACE" get pvc data-pvc -o jsonpath='{.spec.resources.requests.storage}' 2>/dev/null)
if [ "$PVC_REQUEST" = "2Gi" ]; then
  print_pass "Task 2: PVC 'data-pvc' 요청 용량이 2Gi로 확장됨"
  PASS=$((PASS+1))
else
  print_fail "Task 2: PVC 'data-pvc' 요청 용량이 2Gi가 아님 (현재: $PVC_REQUEST)" \
    "kubectl -n $NAMESPACE patch pvc data-pvc -p '{\"spec\":{\"resources\":{\"requests\":{\"storage\":\"2Gi\"}}}}'"
fi

# Task 3: PVC 상태 용량이 2Gi인지 확인 (또는 FileSystemResizePending)
TOTAL=$((TOTAL+1))
PVC_CAPACITY=$(kubectl -n "$NAMESPACE" get pvc data-pvc -o jsonpath='{.status.capacity.storage}' 2>/dev/null)
RESIZE_PENDING=$(kubectl -n "$NAMESPACE" get pvc data-pvc -o jsonpath='{.status.conditions[?(@.type=="FileSystemResizePending")].status}' 2>/dev/null)
if [ "$PVC_CAPACITY" = "2Gi" ]; then
  print_pass "Task 3: PVC 'data-pvc' 실제 용량이 2Gi로 반영됨"
  PASS=$((PASS+1))
elif [ "$RESIZE_PENDING" = "True" ] || [ "$PVC_REQUEST" = "2Gi" ]; then
  print_pass "Task 3: PVC 'data-pvc' 확장 요청 처리 중 (FileSystemResizePending)"
  PASS=$((PASS+1))
else
  print_fail "Task 3: PVC 'data-pvc' 용량 확장 미반영 (현재 capacity: $PVC_CAPACITY)" \
    "StorageClass의 allowVolumeExpansion과 PVC spec을 확인하세요"
fi

# Task 4: Pod가 여전히 Running 상태인지 확인
TOTAL=$((TOTAL+1))
POD_STATUS=$(kubectl -n "$NAMESPACE" get pod volume-pod -o jsonpath='{.status.phase}' 2>/dev/null)
if [ "$POD_STATUS" = "Running" ]; then
  print_pass "Task 4: Pod 'volume-pod'가 Running 상태 유지"
  PASS=$((PASS+1))
else
  print_fail "Task 4: Pod 'volume-pod'가 Running 아님 (현재: $POD_STATUS)" \
    "Pod를 삭제하지 않고 온라인 확장해야 합니다"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
