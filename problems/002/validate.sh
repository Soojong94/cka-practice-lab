#!/bin/bash
# Problem 002: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q002"
PASS=0
TOTAL=0

check_cluster

# Task 1: StorageClass 확인
TOTAL=$((TOTAL+1))
SC_PROVISIONER=$(kubectl get sc local-backup -o jsonpath='{.provisioner}' 2>/dev/null)
SC_RECLAIM=$(kubectl get sc local-backup -o jsonpath='{.reclaimPolicy}' 2>/dev/null)
SC_BINDING=$(kubectl get sc local-backup -o jsonpath='{.volumeBindingMode}' 2>/dev/null)
if [ "$SC_PROVISIONER" = "rancher.io/local-path" ] && [ "$SC_RECLAIM" = "Retain" ] && [ "$SC_BINDING" = "WaitForFirstConsumer" ]; then
  print_pass "Task 1: StorageClass 'local-backup' 올바르게 생성됨"
  PASS=$((PASS+1))
else
  print_fail "Task 1: StorageClass 'local-backup' 스펙 불일치 (provisioner=$SC_PROVISIONER, reclaim=$SC_RECLAIM, binding=$SC_BINDING)" \
    "provisioner, reclaimPolicy, volumeBindingMode 확인"
fi

# Task 2: PVC 확인
TOTAL=$((TOTAL+1))
PVC_SC=$(kubectl -n "$NAMESPACE" get pvc backup-pvc -o jsonpath='{.spec.storageClassName}' 2>/dev/null)
PVC_STATUS=$(kubectl -n "$NAMESPACE" get pvc backup-pvc -o jsonpath='{.status.phase}' 2>/dev/null)
if [ "$PVC_SC" = "local-backup" ] && [ "$PVC_STATUS" = "Bound" ]; then
  print_pass "Task 2: PVC 'backup-pvc' Bound 상태 (storageClass=local-backup)"
  PASS=$((PASS+1))
else
  print_fail "Task 2: PVC 'backup-pvc' 문제 (sc=$PVC_SC, status=$PVC_STATUS)" \
    "storageClassName이 'local-backup'이고 Pod가 PVC를 사용해야 Bound됩니다"
fi

# Task 3: Job 완료 확인
TOTAL=$((TOTAL+1))
JOB_STATUS=$(kubectl -n "$NAMESPACE" get job backup-job -o jsonpath='{.status.succeeded}' 2>/dev/null)
JOB_MOUNT=$(kubectl -n "$NAMESPACE" get job backup-job -o jsonpath='{.spec.template.spec.containers[0].volumeMounts[0].mountPath}' 2>/dev/null)
if [ "$JOB_STATUS" = "1" ] && [ "$JOB_MOUNT" = "/backup" ]; then
  print_pass "Task 3: Job 'backup-job' 성공 완료 (volume mount: /backup)"
  PASS=$((PASS+1))
else
  print_fail "Task 3: Job 'backup-job' 미완료 (succeeded=$JOB_STATUS, mount=$JOB_MOUNT)" \
    "Job이 PVC를 /backup에 마운트하고 성공적으로 완료되어야 합니다"
fi

print_score $PASS $TOTAL
[ $PASS -eq $TOTAL ] && exit 0 || exit 1
