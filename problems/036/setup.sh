#!/bin/bash
# Problem 036: Init Container 실패로 Pod 미시작
# Domain: Troubleshooting
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q036"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. Init Container가 존재하지 않는 서비스를 nslookup하는 Pod 생성
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "Pod 생성 실패"
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
  namespace: $NAMESPACE
  labels:
    app: app-pod
spec:
  initContainers:
  - name: init-check
    image: busybox:1.36
    command: ['sh', '-c', 'until nslookup init-svc.${NAMESPACE}.svc.cluster.local; do echo "Waiting for init-svc..."; sleep 2; done']
  containers:
  - name: app
    image: nginx:1.24-alpine
    ports:
    - containerPort: 80
EOF

# 4. 잠시 대기 (initContainer가 실패 상태 확인)
echo -e "${YELLOW}[INFO] Init Container가 서비스를 찾지 못해 대기 중...${NC}"
sleep 10

# 5. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/036"
echo -e "${YELLOW}[INFO] Pod 'app-pod'의 Init Container가 'init-svc' 서비스를 찾지 못하고 있습니다.${NC}"
