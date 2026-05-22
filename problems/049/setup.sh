#!/bin/bash
# Problem 049: Rolling Update 전략 설정
# Domain: Workloads & Scheduling
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q049"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. Deployment 생성 (nginx:1.24-alpine, 4 replicas)
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "리소스 생성 실패"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
  namespace: $NAMESPACE
spec:
  replicas: 4
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
        image: nginx:1.24-alpine
        ports:
        - containerPort: 80
EOF

# 4. 리소스 Ready 대기
kubectl -n "$NAMESPACE" wait --for=condition=Available deployment/web --timeout=60s || true

# 5. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/049"
