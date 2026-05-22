#!/bin/bash
# Problem 006: ConfigMap을 Volume으로 마운트
# Domain: Configuration
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q006"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. ConfigMap 생성 (nginx 커스텀 설정)
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "ConfigMap 생성 실패"
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
data:
  custom.conf: |
    server {
        listen 80;
        server_name localhost;
        location / {
            return 200 'Hello from CKA ConfigMap Lab!\n';
            add_header Content-Type text/plain;
        }
    }
EOF

# 4. Deployment 생성 (ConfigMap 마운트 없이)
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "Deployment 생성 실패"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-server
  labels:
    app: web-server
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web-server
  template:
    metadata:
      labels:
        app: web-server
    spec:
      containers:
      - name: nginx
        image: nginx:1.25-alpine
        ports:
        - containerPort: 80
EOF

# 5. 리소스 Ready 대기
kubectl -n "$NAMESPACE" wait --for=condition=Available deployment/web-server --timeout=60s || true

# 6. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/006"
