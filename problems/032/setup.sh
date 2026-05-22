#!/bin/bash
# Problem 032: Pod 리소스 제한 초과 OOMKilled
# Domain: Troubleshooting
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q032"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. 메모리 제한이 너무 낮은 Pod 생성 (OOMKilled 유발)
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "Pod 생성 실패"
apiVersion: v1
kind: Pod
metadata:
  name: memory-hog
  namespace: $NAMESPACE
  labels:
    app: memory-hog
spec:
  containers:
  - name: stress
    image: polinux/stress:latest
    command: ["stress"]
    args: ["--vm", "1", "--vm-bytes", "50M", "--vm-hang", "1"]
    resources:
      limits:
        memory: "10Mi"
      requests:
        memory: "5Mi"
EOF

# 4. Pod 상태 확인 (OOMKilled 될 때까지 잠시 대기)
echo -e "${YELLOW}[INFO] Pod가 OOMKilled 상태가 될 때까지 대기 중...${NC}"
sleep 10

# 5. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/032"
echo -e "${YELLOW}[INFO] Pod 'memory-hog'가 OOMKilled 상태일 수 있습니다. 이것이 문제의 시작점입니다.${NC}"
