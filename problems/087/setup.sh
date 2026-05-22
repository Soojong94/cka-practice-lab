#!/bin/bash
# Problem 087: NetworkPolicy 기본 거부 정책
# Domain: Services & Networking
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q087"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. web, api, db Pod 생성
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "리소스 생성 실패"
apiVersion: v1
kind: Pod
metadata:
  name: web
  labels:
    role: web
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
  name: api
  labels:
    role: api
spec:
  containers:
  - name: nginx
    image: nginx:alpine
    command: ["sh", "-c", "nginx -g 'daemon off;' & while true; do sleep 3600; done"]
    ports:
    - containerPort: 8080
---
apiVersion: v1
kind: Pod
metadata:
  name: db
  labels:
    role: db
spec:
  containers:
  - name: busybox
    image: busybox:1.36
    command: ["sh", "-c", "while true; do nc -l -p 5432 -e echo ok; done"]
    ports:
    - containerPort: 5432
EOF

# 4. 리소스 Ready 대기
kubectl -n "$NAMESPACE" wait --for=condition=Ready pod/web --timeout=60s || true
kubectl -n "$NAMESPACE" wait --for=condition=Ready pod/api --timeout=60s || true
kubectl -n "$NAMESPACE" wait --for=condition=Ready pod/db --timeout=60s || true

# 5. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/087"
