#!/bin/bash
# Problem 015: kube-apiserver 장애 복구 (시뮬레이션)
# Domain: Troubleshooting
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q015"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. 잘못된 kube-apiserver 매니페스트를 ConfigMap으로 생성
kubectl apply -n "$NAMESPACE" -f - <<'EOF' || fail_with_cleanup "$NAMESPACE" "리소스 생성 실패"
apiVersion: v1
kind: ConfigMap
metadata:
  name: apiserver-broken-manifest
data:
  manifest: |
    apiVersion: v1
    kind: Pod
    metadata:
      name: kube-apiserver
      namespace: kube-system
      labels:
        component: kube-apiserver
        tier: control-plane
    spec:
      containers:
      - name: kube-apiserver
        image: registry.k8s.io/kube-apiserver:v1.29.0
        command:
        - kube-apiserver
        - --advertise-address=192.168.1.10
        - --allow-privileged=true
        - --authorization-mode=Node,RBAC
        - --client-ca-file=/etc/kubernetes/pki/ca.crt
        - --enable-admission-plugins=NodeRestriction
        - --etcd-cafile=/etc/kubernetes/pki/etcd/ca.crt
        - --etcd-certfile=/etc/kubernetes/pki/apiserver-etcd-client.crt
        - --etcd-keyfile=/etc/kubernetes/pki/apiserver-etcd-client.key
        - --etcd-servers=https://127.0.0.1:1234
        - --kubelet-client-certificate=/etc/kubernetes/pki/apiserver-kubelet-client.crt
        - --kubelet-client-key=/etc/kubernetes/pki/apiserver-kubelet-client.key
        - --secure-port=6443
        - --service-account-issuer=https://kubernetes.default.svc.cluster.local
        - --service-account-key-file=/etc/kubernetes/pki/sa.pub
        - --service-account-signing-key-file=/etc/kubernetes/pki/sa.key
        - --service-cluster-ip-range=10.96.0.0/12
        - --tls-cert-file=/etc/kubernetes/pki/apiserver.crt
        - --tls-private-key-file=/etc/kubernetes/pki/apiserver.key
  error-log: |
    E0115 10:23:45.678901  1234 run.go:74] "command failed" err="context deadline exceeded"
    W0115 10:23:45.679012  1234 clientconn.go:1331] [core] grpc: addrConn.createTransport failed to connect to {127.0.0.1:1234 127.0.0.1}. Err: connection refused
    F0115 10:23:45.679123  1234 instance.go:290] Error creating storage backend for etcd: dial tcp 127.0.0.1:1234: connect: connection refused
EOF

# 4. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/015"
