#!/bin/bash
# Problem 080: Cluster 전체 백업/복원 절차
# Domain: Cluster Architecture, Installation & Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q080"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. 답안 작성용 ConfigMap 생성
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "리소스 생성 실패"
apiVersion: v1
kind: ConfigMap
metadata:
  name: backup-procedure
  namespace: $NAMESPACE
data:
  etcd-backup: "# TODO: etcdctl snapshot save 명령어를 작성하세요 (인증서 플래그 포함, 저장 경로: /backup/etcd-snapshot.db)"
  cert-backup-paths: "# TODO: 백업해야 할 인증서/설정 파일 경로를 나열하세요"
  kubeadm-config: "# TODO: kubeadm 설정 백업 명령어를 작성하세요"
  restore-steps: "# TODO: 복원 절차를 순서대로 기록하세요 (4단계)"
EOF

# 4. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/080"
