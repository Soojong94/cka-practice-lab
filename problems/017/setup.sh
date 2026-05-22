#!/bin/bash
# Problem 017: kube-controller-manager 복구 (시뮬레이션)
# Domain: Troubleshooting
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q017"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. 잘못된 kube-controller-manager 매니페스트를 ConfigMap으로 생성
kubectl apply -n "$NAMESPACE" -f - <<'EOF' || fail_with_cleanup "$NAMESPACE" "리소스 생성 실패"
apiVersion: v1
kind: ConfigMap
metadata:
  name: controller-manager-broken-manifest
data:
  manifest: |
    apiVersion: v1
    kind: Pod
    metadata:
      name: kube-controller-manager
      namespace: kube-system
      labels:
        component: kube-controller-manager
        tier: control-plane
    spec:
      containers:
      - name: kube-controller-manager
        image: registry.k8s.io/kube-controller-manager:v1.29.0
        command:
        - kube-controller-manager
        - --allocate-node-cidrs=true
        - --authentication-kubeconfig=/etc/kubernetes/controller-manager.conf
        - --authorization-kubeconfig=/etc/kubernetes/controller-manager.conf
        - --bind-address=127.0.0.1
        - --client-ca-file=/etc/kubernetes/pki/ca.crt
        - --cluster-cidr=10.244.0.0/16
        - --cluster-name=kubernetes
        - --cluster-signing-cert-file=/etc/kubernetes/pki/wrong-ca.crt
        - --cluster-signing-key-file=/etc/kubernetes/pki/wrong-ca.key
        - --controllers=*,bootstrapsigner,tokencleaner
        - --kubeconfig=/etc/kubernetes/controller-manager.conf
        - --leader-elect=true
        - --root-ca-file=/etc/kubernetes/pki/ca.crt
        - --service-account-private-key-file=/etc/kubernetes/pki/sa.key
        - --service-cluster-ip-range=10.96.0.0/12
        - --use-service-account-credentials=true
        volumeMounts:
        - mountPath: /etc/kubernetes/pki
          name: k8s-certs
          readOnly: true
        - mountPath: /etc/kubernetes/controller-manager.conf
          name: kubeconfig
          readOnly: true
      volumes:
      - hostPath:
          path: /etc/kubernetes/pki
          type: DirectoryOrCreate
        name: k8s-certs
      - hostPath:
          path: /etc/kubernetes/controller-manager.conf
          type: FileOrCreate
        name: kubeconfig
  error-log: |
    E0115 12:00:01.234567  7890 controllermanager.go:245] error starting controllers: open /etc/kubernetes/pki/wrong-ca.crt: no such file or directory
    F0115 12:00:01.234789  7890 server.go:130] unable to start controller manager: failed to initialize cluster signing CA cert/key pair
EOF

# 4. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/017"
