#!/bin/bash
# Problem 073: etcd 멤버 관리
# Domain: Cluster Architecture, Installation & Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q073"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. etcd 클러스터 정보 ConfigMap 생성
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "리소스 생성 실패"
apiVersion: v1
kind: ConfigMap
metadata:
  name: etcd-cluster-info
  namespace: $NAMESPACE
data:
  endpoints: "https://127.0.0.1:2379"
  ca-cert: "/etc/kubernetes/pki/etcd/ca.crt"
  client-cert: "/etc/kubernetes/pki/etcd/server.crt"
  client-key: "/etc/kubernetes/pki/etcd/server.key"
EOF

# 4. 답안 작성용 ConfigMap 생성
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "리소스 생성 실패"
apiVersion: v1
kind: ConfigMap
metadata:
  name: etcd-commands
  namespace: $NAMESPACE
data:
  member-list: "# TODO: etcdctl member list 명령어를 작성하세요 (인증서 플래그 포함)"
  endpoint-health: "# TODO: etcdctl endpoint health 명령어를 작성하세요 (인증서 플래그 포함)"
  endpoint-status: "# TODO: etcdctl endpoint status 명령어를 작성하세요 (인증서 플래그 포함)"
EOF

# 5. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/073"
