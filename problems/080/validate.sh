#!/bin/bash
# Problem 080: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q080"
PASS=0
TOTAL=0

check_cluster

# ConfigMap에서 값 추출
ETCD_BACKUP=$(kubectl -n "$NAMESPACE" get configmap backup-procedure -o jsonpath='{.data.etcd-backup}' 2>/dev/null)
CERT_PATHS=$(kubectl -n "$NAMESPACE" get configmap backup-procedure -o jsonpath='{.data.cert-backup-paths}' 2>/dev/null)
KUBEADM_CONFIG=$(kubectl -n "$NAMESPACE" get configmap backup-procedure -o jsonpath='{.data.kubeadm-config}' 2>/dev/null)
RESTORE_STEPS=$(kubectl -n "$NAMESPACE" get configmap backup-procedure -o jsonpath='{.data.restore-steps}' 2>/dev/null)

# Task 1: etcd-backup에 etcdctl snapshot save 명령어가 있는지
TOTAL=$((TOTAL+1))
if echo "$ETCD_BACKUP" | grep -q 'etcdctl.*snapshot.*save' && echo "$ETCD_BACKUP" | grep -q '\-\-cacert'; then
  print_pass "Task 1: etcd 백업 명령어 올바르게 기록됨"
  PASS=$((PASS+1))
else
  print_fail "Task 1: etcd 백업 명령어 불완전" "etcdctl snapshot save + 인증서 플래그를 포함하세요"
fi

# Task 2: cert-backup-paths에 필수 경로가 있는지
TOTAL=$((TOTAL+1))
HAS_PKI=$(echo "$CERT_PATHS" | grep -c '/etc/kubernetes/pki')
HAS_ADMIN=$(echo "$CERT_PATHS" | grep -c 'admin.conf')
if [ "$HAS_PKI" -ge 1 ] && [ "$HAS_ADMIN" -ge 1 ]; then
  print_pass "Task 2: 인증서 백업 경로 올바르게 기록됨"
  PASS=$((PASS+1))
else
  print_fail "Task 2: 인증서 백업 경로 불완전" "/etc/kubernetes/pki/와 admin.conf를 포함하세요"
fi

# Task 3: kubeadm-config에 백업 명령어가 있는지
TOTAL=$((TOTAL+1))
if echo "$KUBEADM_CONFIG" | grep -q 'kubeadm-config' && echo "$KUBEADM_CONFIG" | grep -q 'kube-system'; then
  print_pass "Task 3: kubeadm 설정 백업 명령어 기록됨"
  PASS=$((PASS+1))
else
  print_fail "Task 3: kubeadm 설정 백업 명령어 불완전" "kubectl -n kube-system get configmap kubeadm-config 명령어를 사용하세요"
fi

# Task 4: restore-steps에 etcd 복원이 있는지
TOTAL=$((TOTAL+1))
if echo "$RESTORE_STEPS" | grep -q 'etcdctl.*snapshot.*restore\|etcd.*복원\|snapshot restore'; then
  print_pass "Task 4: 복원 절차에 etcd 복원 단계 포함"
  PASS=$((PASS+1))
else
  print_fail "Task 4: 복원 절차에 etcd 복원 단계 없음" "etcdctl snapshot restore 단계를 포함하세요"
fi

# Task 5: restore-steps에 kubelet 재시작이 있는지
TOTAL=$((TOTAL+1))
if echo "$RESTORE_STEPS" | grep -q 'systemctl.*restart.*kubelet\|kubelet.*재시작\|restart kubelet'; then
  print_pass "Task 5: 복원 절차에 kubelet 재시작 단계 포함"
  PASS=$((PASS+1))
else
  print_fail "Task 5: 복원 절차에 kubelet 재시작 단계 없음" "systemctl restart kubelet 단계를 포함하세요"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
