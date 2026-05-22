#!/bin/bash
# Problem 014: kubelet 서비스 복구 (시뮬레이션)
# Domain: Troubleshooting
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q014"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. kubelet 장애 시나리오 ConfigMap 생성
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "리소스 생성 실패"
apiVersion: v1
kind: ConfigMap
metadata:
  name: kubelet-scenario
data:
  error-log: |
    -- Logs begin at Mon 2024-01-15 09:00:00 UTC --
    Jan 15 09:01:23 worker-node1 kubelet[1234]: E0115 09:01:23.456789  1234 server.go:302] "Failed to run kubelet" err="failed to run Kubelet: unable to load bootstrap kubeconfig: stat /etc/kubernetes/bootstrap-kubelet.conf: no such file or directory"
    Jan 15 09:01:23 worker-node1 systemd[1]: kubelet.service: Main process exited, code=exited, status=1/FAILURE
    Jan 15 09:01:23 worker-node1 systemd[1]: kubelet.service: Failed with result 'exit-code'.
    Jan 15 09:01:33 worker-node1 systemd[1]: kubelet.service: Scheduled restart job, restart counter is at 5.
    Jan 15 09:01:33 worker-node1 systemd[1]: Started kubelet: The Kubernetes Node Agent.
    Jan 15 09:01:34 worker-node1 kubelet[1290]: E0115 09:01:34.123456  1290 server.go:302] "Failed to run kubelet" err="failed to run Kubelet: invalid kubelet configuration"
    Jan 15 09:01:34 worker-node1 systemd[1]: kubelet.service: Main process exited, code=exited, status=1/FAILURE
  node-info: |
    Node: worker-node1
    OS: Ubuntu 22.04 LTS
    Kubernetes Version: v1.29.0
    kubelet config path: /var/lib/kubelet/config.yaml
    kubelet service file: /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
  instructions: |
    위 로그를 분석하여 kubelet 장애 원인을 파악하고,
    ConfigMap 'kubelet-answer'를 생성하여 올바른 복구 명령어를 작성하세요.
    
    필요한 키:
    - cause: 장애 원인 설명
    - restart-command: kubelet 재시작 명령어
    - enable-command: kubelet 자동 시작 설정 명령어
    - check-command: kubelet 상태 확인 명령어
    - config-path: kubelet 설정 파일 경로
EOF

# 4. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/014"
