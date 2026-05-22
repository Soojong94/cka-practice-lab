#!/bin/bash
# Problem 012: ImagePullBackOff 해결
# Domain: Troubleshooting
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q012"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. 잘못된 이미지 이름으로 Deployment 생성 (ngnix → nginx 오타)
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "리소스 생성 실패"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-deploy
  labels:
    app: web-deploy
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-deploy
  template:
    metadata:
      labels:
        app: web-deploy
    spec:
      containers:
      - name: nginx
        image: ngnix:latest
        ports:
        - containerPort: 80
EOF

# 4. ImagePullBackOff 상태가 될 때까지 대기
echo -e "${YELLOW}[INFO] Pod가 ImagePullBackOff 상태가 되도록 대기 중...${NC}"
sleep 10

# 5. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/012"
