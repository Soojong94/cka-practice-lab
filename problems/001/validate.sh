#!/bin/bash
# Problem 001: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q001"
PASS=0
TOTAL=0

check_cluster

# Task 1: PV 'safari-pv' 존재 여부
TOTAL=$((TOTAL+1))
if kubectl get pv safari-pv &>/dev/null; then
  # 용량 확인
  CAPACITY=$(kubectl get pv safari-pv -o jsonpath='{.spec.capacity.storage}')
  ACCESS=$(kubectl get pv safari-pv -o jsonpath='{.spec.accessModes[0]}')
  HOSTPATH=$(kubectl get pv safari-pv -o jsonpath='{.spec.hostPath.path}')
  if [ "$CAPACITY" = "2Gi" ] && [ "$ACCESS" = "ReadWriteOnce" ] && [ "$HOSTPATH" = "/Volumes/Data" ]; then
    print_pass "Task 1: PV 'safari-pv' 올바르게 생성됨 (2Gi, RWO, /Volumes/Data)"
    PASS=$((PASS+1))
  else
    print_fail "Task 1: PV 'safari-pv' 스펙 불일치 (capacity=$CAPACITY, access=$ACCESS, path=$HOSTPATH)" \
      "용량 2Gi, accessModes ReadWriteOnce, hostPath /Volumes/Data 확인"
  fi
else
  print_fail "Task 1: PV 'safari-pv' 미생성" "kubectl apply -f 로 PV를 생성하세요"
fi

# Task 2: PVC 'safari-pvc' 존재 여부
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get pvc safari-pvc &>/dev/null; then
  PVC_CAPACITY=$(kubectl -n "$NAMESPACE" get pvc safari-pvc -o jsonpath='{.spec.resources.requests.storage}')
  PVC_ACCESS=$(kubectl -n "$NAMESPACE" get pvc safari-pvc -o jsonpath='{.spec.accessModes[0]}')
  if [ "$PVC_CAPACITY" = "2Gi" ] && [ "$PVC_ACCESS" = "ReadWriteOnce" ]; then
    print_pass "Task 2: PVC 'safari-pvc' 올바르게 생성됨 (2Gi, RWO)"
    PASS=$((PASS+1))
  else
    print_fail "Task 2: PVC 'safari-pvc' 스펙 불일치 (capacity=$PVC_CAPACITY, access=$PVC_ACCESS)" \
      "요청 용량 2Gi, accessModes ReadWriteOnce 확인"
  fi
else
  print_fail "Task 2: PVC 'safari-pvc' 미생성" "네임스페이스 cka-q001에 PVC를 생성하세요"
fi

# Task 3: PVC가 Bound 상태인지
TOTAL=$((TOTAL+1))
PVC_STATUS=$(kubectl -n "$NAMESPACE" get pvc safari-pvc -o jsonpath='{.status.phase}' 2>/dev/null)
if [ "$PVC_STATUS" = "Bound" ]; then
  print_pass "Task 3: PVC 'safari-pvc' Bound 상태"
  PASS=$((PASS+1))
else
  print_fail "Task 3: PVC 'safari-pvc' Bound 아님 (현재: $PVC_STATUS)" \
    "PV와 PVC의 accessModes, capacity, storageClassName이 일치하는지 확인"
fi

# Task 4: Deployment에 volume mount 설정
TOTAL=$((TOTAL+1))
MOUNT_PATH=$(kubectl -n "$NAMESPACE" get deployment safari -o jsonpath='{.spec.template.spec.containers[0].volumeMounts[?(@.mountPath=="/tmp/safari-data")].mountPath}' 2>/dev/null)
VOLUME_PVC=$(kubectl -n "$NAMESPACE" get deployment safari -o jsonpath='{.spec.template.spec.volumes[?(@.persistentVolumeClaim.claimName=="safari-pvc")].name}' 2>/dev/null)
if [ "$MOUNT_PATH" = "/tmp/safari-data" ] && [ -n "$VOLUME_PVC" ]; then
  print_pass "Task 4: Deployment 'safari'에 PVC 마운트 설정됨 (/tmp/safari-data)"
  PASS=$((PASS+1))
else
  print_fail "Task 4: Deployment 'safari'에 volume mount 미설정" \
    "deployment를 edit하여 volumes와 volumeMounts를 추가하세요"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
