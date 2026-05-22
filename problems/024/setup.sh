#!/bin/bash
# Problem 024: 인증서 만료 확인 및 갱신 (simulated)
# Domain: Troubleshooting
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q024"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. 인증서 정보를 시뮬레이션하는 ConfigMap 생성
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "리소스 생성 실패"
apiVersion: v1
kind: ConfigMap
metadata:
  name: cert-info
data:
  apiserver-cert: |
    Certificate:
        Data:
            Version: 3 (0x2)
            Serial Number: 1234567890
            Signature Algorithm: sha256WithRSAEncryption
            Issuer: CN = kubernetes
            Validity
                Not Before: Jan 15 00:00:00 2024 GMT
                Not After : Jan 15 00:00:00 2025 GMT
            Subject: CN = kube-apiserver
            Subject Public Key Info:
                Public Key Algorithm: rsaEncryption
                    RSA Public-Key: (2048 bit)
            X509v3 extensions:
                X509v3 Subject Alternative Names:
                    DNS:kubernetes, DNS:kubernetes.default, DNS:kubernetes.default.svc
                    IP Address:10.96.0.1, IP Address:192.168.65.4
  kubeadm-certs-output: |
    CERTIFICATE                EXPIRES                  RESIDUAL TIME   CERTIFICATE AUTHORITY   EXTERNALLY MANAGED
    admin.conf                 Jan 15, 2025 00:00 UTC   30d             ca                      no
    apiserver                  Jan 15, 2025 00:00 UTC   30d             ca                      no
    apiserver-etcd-client      Jan 15, 2025 00:00 UTC   30d             etcd-ca                 no
    apiserver-kubelet-client   Jan 15, 2025 00:00 UTC   30d             ca                      no
    controller-manager.conf    Jan 15, 2025 00:00 UTC   30d             ca                      no
    etcd-healthcheck-client    Jan 15, 2025 00:00 UTC   30d             etcd-ca                 no
    etcd-peer                  Jan 15, 2025 00:00 UTC   30d             etcd-ca                 no
    etcd-server                Jan 15, 2025 00:00 UTC   30d             etcd-ca                 no
    front-proxy-client         Jan 15, 2025 00:00 UTC   30d             front-proxy-ca          no
    scheduler.conf             Jan 15, 2025 00:00 UTC   30d             ca                      no
EOF

# 4. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/024"
