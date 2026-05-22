#!/bin/bash
# Problem 072: etcd 스냅샷 백업 및 복원
# Domain: Cluster Architecture, Installation & Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q072"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. etcd 정보를 담은 ConfigMap 생성
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "리소스 생성 실패"
apiVersion: v1
kind: ConfigMap
metadata:
  name: etcd-info
  namespace: $NAMESPACE
data:
  endpoint: "https://127.0.0.1:2379"
  ca-cert: "/etc/kubernetes/pki/etcd/ca.crt"
  server-cert: "/etc/kubernetes/pki/etcd/server.crt"
  server-key: "/etc/kubernetes/pki/etcd/server.key"
  snapshot-path: "/tmp/etcd-backup.db"
  restore-dir: "/var/lib/etcd-restored"
EOF

# 4. 스크립트 파일을 저장할 빈 ConfigMap 생성
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "리소스 생성 실패"
apiVersion: v1
kind: ConfigMap
metadata:
  name: etcd-scripts
  namespace: $NAMESPACE
data:
  backup.sh: |
    #!/bin/bash
    # TODO: etcdctl snapshot save 명령어를 작성하세요
    # 필수 플래그: --cacert, --cert, --key, --endpoints
    # 스냅샷 저장 경로: /tmp/etcd-backup.db
  restore.sh: |
    #!/bin/bash
    # TODO: etcdctl snapshot restore 명령어를 작성하세요
    # 복원 디렉토리: /var/lib/etcd-restored
EOF

# 5. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/072"
