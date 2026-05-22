#!/bin/bash
# Problem 022: Node NotReady 상태 해결 (simulated)
# Domain: Troubleshooting
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q022"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. Node describe 출력을 시뮬레이션하는 ConfigMap 생성
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "리소스 생성 실패"
apiVersion: v1
kind: ConfigMap
metadata:
  name: node-describe-output
data:
  node-status: |
    Name:               worker-node-1
    Roles:              <none>
    Labels:             kubernetes.io/hostname=worker-node-1
    Conditions:
      Type             Status  LastHeartbeatTime                 Reason                       Message
      ----             ------  -----------------                 ------                       -------
      MemoryPressure   False   2024-01-15T10:30:00Z              KubeletHasSufficientMemory   kubelet has sufficient memory available
      DiskPressure     False   2024-01-15T10:30:00Z              KubeletHasNoDiskPressure     kubelet has no disk pressure
      PIDPressure      False   2024-01-15T10:30:00Z              KubeletHasSufficientPID      kubelet has sufficient PID available
      Ready            False   2024-01-15T09:15:00Z              KubeletNotReady              container runtime not ready: certificate has expired
  kubelet-logs: |
    Jan 15 09:15:01 worker-node-1 kubelet[1234]: E0115 09:15:01.123456 1234 certificate_manager.go:557] kubelet certificate has expired
    Jan 15 09:15:01 worker-node-1 kubelet[1234]: E0115 09:15:01.234567 1234 server.go:302] failed to run Kubelet: unable to load TLS certificate: tls: failed to find any PEM data in certificate input
    Jan 15 09:15:02 worker-node-1 kubelet[1234]: E0115 09:15:02.345678 1234 reflector.go:138] pkg/kubelet/kubelet.go:458: Failed to watch *v1.Node: failed to list *v1.Node: Unauthorized
    Jan 15 09:15:03 worker-node-1 kubelet[1234]: I0115 09:15:03.456789 1234 certificate_manager.go:440] Current certificate is expired, requesting new certificate
    Jan 15 09:15:04 worker-node-1 kubelet[1234]: E0115 09:15:04.567890 1234 bootstrap.go:265] Part of the existing bootstrap client certificate is expired: 2024-01-15 09:00:00 +0000 UTC
EOF

# 4. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/022"
