#!/bin/bash
# Problem 011: CrashLoopBackOff Pod 디버깅
# Domain: Troubleshooting
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q011"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. 잘못된 커맨드로 CrashLoopBackOff 상태의 Pod 생성
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "리소스 생성 실패"
apiVersion: v1
kind: Pod
metadata:
  name: crash-pod
  labels:
    app: crash-pod
spec:
  containers:
  - name: busybox
    image: busybox:1.36
    command: ["sleeeep", "3600"]
EOF

# 4. Pod가 CrashLoopBackOff 상태가 될 때까지 잠시 대기
echo -e "${YELLOW}[INFO] Pod가 CrashLoopBackOff 상태가 되도록 대기 중...${NC}"
sleep 5

# 5. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/011"
