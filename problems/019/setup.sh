#!/bin/bash
# Problem 019: Service 연결 불가 트러블슈팅
# Domain: Troubleshooting
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q019"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. Deployment 생성 (라벨: app=web)
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "리소스 생성 실패"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  labels:
    app: web
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: nginx
        image: nginx:1.25-alpine
        ports:
        - containerPort: 80
EOF

# 4. 잘못된 selector로 Service 생성 (app=webapp, 실제 Pod는 app=web)
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "Service 생성 실패"
apiVersion: v1
kind: Service
metadata:
  name: web-svc
spec:
  selector:
    app: webapp
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
  type: ClusterIP
EOF

# 5. Deployment Ready 대기
kubectl -n "$NAMESPACE" wait --for=condition=Available deployment/web-app --timeout=60s || true

# 6. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/019"
