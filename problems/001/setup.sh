#!/bin/bash
# Problem 001: PV/PVC 생성 및 Pod 마운트
# Domain: Storage
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q001"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. 문제에 필요한 리소스 생성
# 이미 동작 중인 웹 서버 Pod (볼륨 마운트 없이)
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "리소스 생성 실패"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: safari
  labels:
    app: safari
spec:
  replicas: 1
  selector:
    matchLabels:
      app: safari
  template:
    metadata:
      labels:
        app: safari
    spec:
      containers:
      - name: httpd
        image: httpd:2-alpine
        ports:
        - containerPort: 80
EOF

# 4. 리소스 Ready 대기
kubectl -n "$NAMESPACE" wait --for=condition=Available deployment/safari --timeout=60s || true

# 5. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/001"
