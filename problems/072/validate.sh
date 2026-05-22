#!/bin/bash
# Problem 072: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q072"
PASS=0
TOTAL=0

check_cluster

# ConfigMap에서 스크립트 내용 추출
BACKUP_SH=$(kubectl -n "$NAMESPACE" get configmap etcd-scripts -o jsonpath='{.data.backup\.sh}' 2>/dev/null)
RESTORE_SH=$(kubectl -n "$NAMESPACE" get configmap etcd-scripts -o jsonpath='{.data.restore\.sh}' 2>/dev/null)

# Task 1: backup.sh에 etcdctl snapshot save 명령어가 있는지
TOTAL=$((TOTAL+1))
if echo "$BACKUP_SH" | grep -q 'etcdctl.*snapshot.*save'; then
  print_pass "Task 1: backup.sh에 etcdctl snapshot save 명령어 포함"
  PASS=$((PASS+1))
else
  print_fail "Task 1: backup.sh에 etcdctl snapshot save 명령어 없음" "etcdctl snapshot save 명령어를 작성하세요"
fi

# Task 2: backup.sh에 필수 플래그가 모두 있는지
TOTAL=$((TOTAL+1))
HAS_CACERT=$(echo "$BACKUP_SH" | grep -c '\-\-cacert.*ca\.crt')
HAS_CERT=$(echo "$BACKUP_SH" | grep -c '\-\-cert.*server\.crt')
HAS_KEY=$(echo "$BACKUP_SH" | grep -c '\-\-key.*server\.key')
HAS_ENDPOINTS=$(echo "$BACKUP_SH" | grep -c '\-\-endpoints.*https://127\.0\.0\.1:2379')
if [ "$HAS_CACERT" -ge 1 ] && [ "$HAS_CERT" -ge 1 ] && [ "$HAS_KEY" -ge 1 ] && [ "$HAS_ENDPOINTS" -ge 1 ]; then
  print_pass "Task 2: backup.sh에 --cacert, --cert, --key, --endpoints 플래그 모두 포함"
  PASS=$((PASS+1))
else
  print_fail "Task 2: backup.sh에 필수 플래그 누락" "--cacert, --cert, --key, --endpoints 플래그를 모두 포함하세요"
fi

# Task 3: backup.sh에 스냅샷 경로가 있는지
TOTAL=$((TOTAL+1))
if echo "$BACKUP_SH" | grep -q '/tmp/etcd-backup\.db'; then
  print_pass "Task 3: backup.sh에 스냅샷 경로 /tmp/etcd-backup.db 포함"
  PASS=$((PASS+1))
else
  print_fail "Task 3: backup.sh에 스냅샷 경로 없음" "스냅샷 저장 경로를 /tmp/etcd-backup.db로 지정하세요"
fi

# Task 4: restore.sh에 etcdctl snapshot restore 명령어가 있는지
TOTAL=$((TOTAL+1))
if echo "$RESTORE_SH" | grep -q 'etcdctl.*snapshot.*restore'; then
  print_pass "Task 4: restore.sh에 etcdctl snapshot restore 명령어 포함"
  PASS=$((PASS+1))
else
  print_fail "Task 4: restore.sh에 etcdctl snapshot restore 명령어 없음" "etcdctl snapshot restore 명령어를 작성하세요"
fi

# Task 5: restore.sh에 --data-dir 플래그가 있는지
TOTAL=$((TOTAL+1))
if echo "$RESTORE_SH" | grep -q '\-\-data-dir.*/var/lib/etcd-restored'; then
  print_pass "Task 5: restore.sh에 --data-dir=/var/lib/etcd-restored 포함"
  PASS=$((PASS+1))
else
  print_fail "Task 5: restore.sh에 --data-dir 플래그 없음" "--data-dir=/var/lib/etcd-restored를 포함하세요"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
