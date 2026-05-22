#!/bin/bash
# Problem 025: etcd 클러스터 상태 확인 (simulated)
# Domain: Troubleshooting
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q025"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. etcd Pod manifest를 시뮬레이션하는 ConfigMap 생성
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "리소스 생성 실패"
apiVersion: v1
kind: ConfigMap
metadata:
  name: etcd-manifest
data:
  etcd-pod.yaml: |
    apiVersion: v1
    kind: Pod
    metadata:
      name: etcd-master
      namespace: kube-system
    spec:
      containers:
      - name: etcd
        image: registry.k8s.io/etcd:3.5.9-0
        command:
        - etcd
        - --advertise-client-urls=https://192.168.65.4:2379
        - --cert-file=/etc/kubernetes/pki/etcd/server.crt
        - --client-cert-auth=true
        - --data-dir=/var/lib/etcd
        - --initial-advertise-peer-urls=https://192.168.65.4:2380
        - --initial-cluster=master=https://192.168.65.4:2380
        - --key-file=/etc/kubernetes/pki/etcd/server.key
        - --listen-client-urls=https://127.0.0.1:2379,https://192.168.65.4:2379
        - --listen-peer-urls=https://192.168.65.4:2380
        - --name=master
        - --peer-cert-file=/etc/kubernetes/pki/etcd/peer.crt
        - --peer-client-cert-auth=true
        - --peer-key-file=/etc/kubernetes/pki/etcd/peer.key
        - --peer-trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt
        - --snapshot-count=10000
        - --trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt
        volumeMounts:
        - mountPath: /var/lib/etcd
          name: etcd-data
        - mountPath: /etc/kubernetes/pki/etcd
          name: etcd-certs
      volumes:
      - hostPath:
          path: /var/lib/etcd
        name: etcd-data
      - hostPath:
          path: /etc/kubernetes/pki/etcd
        name: etcd-certs
EOF

# 4. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/025"
