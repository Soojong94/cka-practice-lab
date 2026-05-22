#!/bin/bash
# Problem 027: Deployment rollout 실패 복구
# Domain: Troubleshooting
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q027"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. 정상 Deployment 생성 (nginx:alpine)
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
        image: nginx:alpine
        ports:
        - containerPort: 80
EOF

# 4. 정상 배포 완료 대기
kubectl -n "$NAMESPACE" wait --for=condition=Available deployment/web-deploy --timeout=60s || true

# 5. 잘못된 이미지로 업데이트하여 rollout 실패 유도
kubectl -n "$NAMESPACE" set image deployment/web-deploy nginx=nginx:nonexistent-version-v999

# 6. 잠시 대기하여 실패 상태 발생
sleep 10

# 7. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/027"
