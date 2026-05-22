#!/bin/bash
# Problem 013: Pending Pod 원인 분석 및 해결
# Domain: Troubleshooting
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q013"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. 과도한 메모리 요청으로 스케줄링 불가능한 Pod 생성
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "리소스 생성 실패"
apiVersion: v1
kind: Pod
metadata:
  name: memory-hog
  labels:
    app: memory-hog
spec:
  containers:
  - name: busybox
    image: busybox:1.36
    command: ["sleep", "3600"]
    resources:
      requests:
        memory: "100Gi"
EOF

# 4. 존재하지 않는 nodeSelector로 스케줄링 불가능한 Pod 생성
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "리소스 생성 실패"
apiVersion: v1
kind: Pod
metadata:
  name: node-selector-pod
  labels:
    app: node-selector-pod
spec:
  nodeSelector:
    disktype: superfast-nvme
  containers:
  - name: busybox
    image: busybox:1.36
    command: ["sleep", "3600"]
    resources:
      requests:
        memory: "64Mi"
EOF

# 5. Pending 상태 확인 대기
echo -e "${YELLOW}[INFO] Pod가 Pending 상태가 되도록 대기 중...${NC}"
sleep 5

# 6. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/013"
