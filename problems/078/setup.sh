#!/bin/bash
# Problem 078: 인증서 체인 확인
# Domain: Cluster Architecture, Installation & Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q078"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. 인증서 경로 정보 ConfigMap 생성
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "리소스 생성 실패"
apiVersion: v1
kind: ConfigMap
metadata:
  name: cert-paths
  namespace: $NAMESPACE
data:
  ca-cert-path: "/etc/kubernetes/pki/ca.crt"
  ca-key-path: "/etc/kubernetes/pki/ca.key"
  apiserver-cert-path: "/etc/kubernetes/pki/apiserver.crt"
  apiserver-key-path: "/etc/kubernetes/pki/apiserver.key"
  apiserver-kubelet-client-cert: "/etc/kubernetes/pki/apiserver-kubelet-client.crt"
  apiserver-kubelet-client-key: "/etc/kubernetes/pki/apiserver-kubelet-client.key"
  etcd-ca-cert: "/etc/kubernetes/pki/etcd/ca.crt"
  front-proxy-ca-cert: "/etc/kubernetes/pki/front-proxy-ca.crt"
EOF

# 4. 답안 작성용 ConfigMap 생성
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "리소스 생성 실패"
apiVersion: v1
kind: ConfigMap
metadata:
  name: cert-chain-info
  namespace: $NAMESPACE
data:
  ca-cert: "# TODO: CA 인증서 정보를 기록하세요 (path, issuer, subject, role)"
  apiserver-cert: "# TODO: API 서버 인증서 정보를 기록하세요 (path, issuer, subject, role)"
  apiserver-kubelet-client: "# TODO: kubelet 클라이언트 인증서 정보를 기록하세요 (path, issuer, subject, role)"
EOF

# 5. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/078"
