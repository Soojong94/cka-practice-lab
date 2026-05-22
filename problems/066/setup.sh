#!/bin/bash
# Problem 066: Node drain 및 cordon
# Domain: Cluster Architecture, Installation & Configuration
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q066"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. 노드가 스케줄 가능한 상태인지 확인 (이전 실행 잔여물 정리)
kubectl uncordon docker-desktop 2>/dev/null || true

# 4. Deployment 생성
kubectl -n "$NAMESPACE" apply -f - <<EOF || fail_with_cleanup "$NAMESPACE" "리소스 생성 실패"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  labels:
    app: web-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
---
apiVersion: v1
kind: Pod
metadata:
  name: standalone-pod
  labels:
    app: standalone
spec:
  containers:
  - name: busybox
    image: busybox:latest
    command: ["sleep", "3600"]
EOF

# 5. 리소스 Ready 대기
kubectl -n "$NAMESPACE" wait --for=condition=Available deployment/web-app --timeout=60s || true
kubectl -n "$NAMESPACE" wait --for=condition=Ready pod/standalone-pod --timeout=60s || true

# 6. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/066"
