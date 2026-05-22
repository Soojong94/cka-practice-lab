#!/bin/bash
# Problem 077: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q077"
PASS=0
TOTAL=0

check_cluster

# ConfigMap에서 값 추출
CSI_DRIVERS=$(kubectl -n "$NAMESPACE" get configmap csi-info -o jsonpath='{.data.csi-drivers}' 2>/dev/null)
STORAGE_CLASSES=$(kubectl -n "$NAMESPACE" get configmap csi-info -o jsonpath='{.data.storage-classes}' 2>/dev/null)
DEFAULT_SC=$(kubectl -n "$NAMESPACE" get configmap csi-info -o jsonpath='{.data.default-storage-class}' 2>/dev/null)

# Task 1: csi-drivers에 값이 기록되었는지
TOTAL=$((TOTAL+1))
if [ -n "$CSI_DRIVERS" ] && ! echo "$CSI_DRIVERS" | grep -q 'TODO'; then
  print_pass "Task 1: CSI 드라이버 목록 기록됨 ($CSI_DRIVERS)"
  PASS=$((PASS+1))
else
  print_fail "Task 1: CSI 드라이버 목록이 기록되지 않음" "kubectl get csidrivers로 확인하세요"
fi

# Task 2: storage-classes에 provisioner 정보가 있는지
TOTAL=$((TOTAL+1))
if [ -n "$STORAGE_CLASSES" ] && ! echo "$STORAGE_CLASSES" | grep -q 'TODO'; then
  print_pass "Task 2: StorageClass 정보 기록됨"
  PASS=$((PASS+1))
else
  print_fail "Task 2: StorageClass 정보가 기록되지 않음" "kubectl get sc로 확인하세요"
fi

# Task 3: default-storage-class에 값이 있는지
TOTAL=$((TOTAL+1))
if [ -n "$DEFAULT_SC" ] && ! echo "$DEFAULT_SC" | grep -q 'TODO'; then
  # 실제 기본 StorageClass와 비교
  ACTUAL_DEFAULT=$(kubectl get sc -o jsonpath='{range .items[?(@.metadata.annotations.storageclass\.kubernetes\.io/is-default-class=="true")]}{.metadata.name}{end}' 2>/dev/null)
  if [ "$DEFAULT_SC" = "$ACTUAL_DEFAULT" ] || [ -n "$DEFAULT_SC" ]; then
    print_pass "Task 3: 기본 StorageClass 기록됨 ($DEFAULT_SC)"
    PASS=$((PASS+1))
  else
    print_fail "Task 3: 기본 StorageClass가 올바르지 않음 (기대: $ACTUAL_DEFAULT, 실제: $DEFAULT_SC)" "annotation을 확인하세요"
  fi
else
  print_fail "Task 3: 기본 StorageClass가 기록되지 않음" "kubectl get sc에서 (default) 표시된 것을 확인하세요"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
