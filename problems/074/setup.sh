#!/bin/bash
# Problem 074: kubelet 설정 확인 및 수정
# Domain: Cluster Architecture, Installation & Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q074"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. 오류가 포함된 kubelet 설정 ConfigMap 생성
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "리소스 생성 실패"
apiVersion: v1
kind: ConfigMap
metadata:
  name: kubelet-config
  namespace: $NAMESPACE
data:
  config.yaml: |
    apiVersion: kubelet.config.k8s.io/v1beta1
    kind: KubeletConfiguration
    clusterDomain: cluster.local
    clusterDNS:
    - 10.96.0.1
    staticPodPath: /etc/kubernetes/static-pods
    authentication:
      anonymous:
        enabled: true
    cgroupDriver: systemd
    containerRuntimeEndpoint: unix:///var/run/containerd/containerd.sock
    rotateCertificates: true
    serverTLSBootstrap: true
EOF

# 4. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/074"
