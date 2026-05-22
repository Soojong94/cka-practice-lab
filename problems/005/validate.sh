#!/bin/bash
# Problem 005: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q005"
PASS=0
TOTAL=0

check_cluster

# Task 1: PV 'shared-pv' 존재 및 스펙 확인
TOTAL=$((TOTAL+1))
if kubectl get pv shared-pv &>/dev/null; then
  CAPACITY=$(kubectl get pv shared-pv -o jsonpath='{.spec.capacity.storage}')
  ACCESS=$(kubectl get pv shared-pv -o jsonpath='{.spec.accessModes[0]}')
  HOSTPATH=$(kubectl get pv shared-pv -o jsonpath='{.spec.hostPath.path}')
  SC=$(kubectl get pv shared-pv -o jsonpath='{.spec.storageClassName}')
  if [ "$CAPACITY" = "1Gi" ] && [ "$ACCESS" = "ReadWriteMany" ] && [ "$HOSTPATH" = "/tmp/shared-data" ] && [ "$SC" = "manual" ]; then
    print_pass "Task 1: PV 'shared-pv' 올바르게 생성됨 (1Gi, RWX, hostPath=/tmp/shared-data, sc=manual)"
    PASS=$((PASS+1))
  else
    print_fail "Task 1: PV 'shared-pv' 스펙 불일치 (capacity=$CAPACITY, access=$ACCESS, path=$HOSTPATH, sc=$SC)" \
      "용량 1Gi, accessModes ReadWriteMany, hostPath /tmp/shared-data, storageClassName manual 확인"
  fi
else
  print_fail "Task 1: PV 'shared-pv' 미생성" "kubectl apply -f 로 PV를 생성하세요"
fi

# Task 2: PVC 'shared-pvc' 존재 및 Bound 상태
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get pvc shared-pvc &>/dev/null; then
  PVC_STATUS=$(kubectl -n "$NAMESPACE" get pvc shared-pvc -o jsonpath='{.status.phase}')
  PVC_ACCESS=$(kubectl -n "$NAMESPACE" get pvc shared-pvc -o jsonpath='{.spec.accessModes[0]}')
  if [ "$PVC_STATUS" = "Bound" ] && [ "$PVC_ACCESS" = "ReadWriteMany" ]; then
    print_pass "Task 2: PVC 'shared-pvc' Bound 상태 (RWX)"
    PASS=$((PASS+1))
  else
    print_fail "Task 2: PVC 'shared-pvc' 상태 불일치 (status=$PVC_STATUS, access=$PVC_ACCESS)" \
      "PVC의 accessModes와 storageClassName이 PV와 일치하는지 확인"
  fi
else
  print_fail "Task 2: PVC 'shared-pvc' 미생성" "네임스페이스 $NAMESPACE에 PVC를 생성하세요"
fi

# Task 3: writer-pod 존재 및 Running 상태, 볼륨 마운트 확인
TOTAL=$((TOTAL+1))
WRITER_STATUS=$(kubectl -n "$NAMESPACE" get pod writer-pod -o jsonpath='{.status.phase}' 2>/dev/null)
WRITER_MOUNT=$(kubectl -n "$NAMESPACE" get pod writer-pod -o jsonpath='{.spec.containers[0].volumeMounts[?(@.mountPath=="/shared")].mountPath}' 2>/dev/null)
if [ "$WRITER_STATUS" = "Running" ] && [ "$WRITER_MOUNT" = "/shared" ]; then
  print_pass "Task 3: Pod 'writer-pod' Running 상태, /shared 마운트됨"
  PASS=$((PASS+1))
else
  print_fail "Task 3: Pod 'writer-pod' 상태 불일치 (status=$WRITER_STATUS, mount=$WRITER_MOUNT)" \
    "writer-pod가 Running이고 PVC를 /shared에 마운트해야 합니다"
fi

# Task 4: reader-pod 존재 및 Running 상태, 볼륨 마운트 확인
TOTAL=$((TOTAL+1))
READER_STATUS=$(kubectl -n "$NAMESPACE" get pod reader-pod -o jsonpath='{.status.phase}' 2>/dev/null)
READER_MOUNT=$(kubectl -n "$NAMESPACE" get pod reader-pod -o jsonpath='{.spec.containers[0].volumeMounts[?(@.mountPath=="/shared")].mountPath}' 2>/dev/null)
if [ "$READER_STATUS" = "Running" ] && [ "$READER_MOUNT" = "/shared" ]; then
  print_pass "Task 4: Pod 'reader-pod' Running 상태, /shared 마운트됨"
  PASS=$((PASS+1))
else
  print_fail "Task 4: Pod 'reader-pod' 상태 불일치 (status=$READER_STATUS, mount=$READER_MOUNT)" \
    "reader-pod가 Running이고 PVC를 /shared에 마운트해야 합니다"
fi

# Task 5: 데이터 공유 확인 (writer가 쓴 파일을 reader가 읽을 수 있는지)
TOTAL=$((TOTAL+1))
DATA_CONTENT=$(kubectl -n "$NAMESPACE" exec reader-pod -- cat /shared/data.txt 2>/dev/null)
if echo "$DATA_CONTENT" | grep -q "hello from writer"; then
  print_pass "Task 5: reader-pod에서 writer-pod가 작성한 데이터 읽기 성공"
  PASS=$((PASS+1))
else
  print_fail "Task 5: reader-pod에서 /shared/data.txt 읽기 실패 (내용: $DATA_CONTENT)" \
    "writer-pod가 /shared/data.txt에 데이터를 쓰고, reader-pod가 같은 PVC를 마운트해야 합니다"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
