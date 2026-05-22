#!/bin/bash
# Problem 085: NetworkPolicy Ingress 규칙
# Domain: Services & Networking
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q085"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. frontend Pod 생성
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "리소스 생성 실패"
apiVersion: v1
kind: Pod
metadata:
  name: frontend
  labels:
    role: frontend
spec:
  containers:
  - name: curl
    image: curlimages/curl:latest
    command: ["sleep", "3600"]
---
apiVersion: v1
kind: Pod
metadata:
  name: backend
  labels:
    role: backend
spec:
  containers:
  - name: nginx
    image: nginx:alpine
    ports:
    - containerPort: 80
---
apiVersion: v1
kind: Pod
metadata:
  name: other
  labels:
    role: other
spec:
  containers:
  - name: curl
    image: curlimages/curl:latest
    command: ["sleep", "3600"]
EOF

# 4. 리소스 Ready 대기
kubectl -n "$NAMESPACE" wait --for=condition=Ready pod/frontend --timeout=60s || true
kubectl -n "$NAMESPACE" wait --for=condition=Ready pod/backend --timeout=60s || true
kubectl -n "$NAMESPACE" wait --for=condition=Ready pod/other --timeout=60s || true

# 5. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/085"
