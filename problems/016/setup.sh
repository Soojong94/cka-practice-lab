#!/bin/bash
# Problem 016: kube-scheduler 장애 복구 (시뮬레이션)
# Domain: Troubleshooting
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q016"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. 잘못된 kube-scheduler 매니페스트를 ConfigMap으로 생성
kubectl apply -n "$NAMESPACE" -f - <<'EOF' || fail_with_cleanup "$NAMESPACE" "리소스 생성 실패"
apiVersion: v1
kind: ConfigMap
metadata:
  name: scheduler-broken-manifest
data:
  manifest: |
    apiVersion: v1
    kind: Pod
    metadata:
      name: kube-scheduler
      namespace: kube-system
      labels:
        component: kube-scheduler
        tier: control-plane
    spec:
      containers:
      - name: kube-scheduler
        image: registry.k8s.io/kube-scheduler:v1.29.0
        command:
        - kube-scheduler
        - --authentication-kubeconfig=/etc/kubernetes/scheduler-wrong.conf
        - --authorization-kubeconfig=/etc/kubernetes/scheduler-wrong.conf
        - --bind-address=127.0.0.1
        - --kubeconfig=/etc/kubernetes/scheduler-wrong.conf
        - --leader-elect=true
        volumeMounts:
        - mountPath: /etc/kubernetes/scheduler.conf
          name: kubeconfig
          readOnly: true
      volumes:
      - hostPath:
          path: /etc/kubernetes/scheduler.conf
          type: FileOrCreate
        name: kubeconfig
  error-log: |
    E0115 11:00:01.234567  5678 run.go:74] "command failed" err="unable to load client config: unable to read kubeconfig: open /etc/kubernetes/scheduler-wrong.conf: no such file or directory"
    F0115 11:00:01.234789  5678 server.go:130] unable to load client config
EOF

# 4. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/016"
