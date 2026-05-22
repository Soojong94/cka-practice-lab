#!/bin/bash
# Problem 067: kubectl 정렬 및 jsonpath 출력
# Domain: Cluster Architecture, Installation & Configuration
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q067"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. 여러 Pod 생성 (다른 시간에 생성되도록 sleep 추가)
kubectl -n "$NAMESPACE" apply -f - <<EOF || fail_with_cleanup "$NAMESPACE" "리소스 생성 실패"
apiVersion: v1
kind: Pod
metadata:
  name: pod-alpha
  labels:
    app: web
    tier: frontend
    version: v1
spec:
  containers:
  - name: nginx
    image: nginx:alpine
EOF

sleep 2

kubectl -n "$NAMESPACE" apply -f - <<EOF || true
apiVersion: v1
kind: Pod
metadata:
  name: pod-beta
  labels:
    app: api
    tier: backend
    version: v2
spec:
  containers:
  - name: nginx
    image: nginx:alpine
EOF

sleep 2

kubectl -n "$NAMESPACE" apply -f - <<EOF || true
apiVersion: v1
kind: Pod
metadata:
  name: pod-gamma
  labels:
    app: db
    tier: backend
    version: v1
spec:
  containers:
  - name: busybox
    image: busybox:latest
    command: ["sleep", "3600"]
EOF

sleep 2

kubectl -n "$NAMESPACE" apply -f - <<EOF || true
apiVersion: v1
kind: Pod
metadata:
  name: pod-delta
  labels:
    app: cache
    tier: middleware
    version: v3
spec:
  containers:
  - name: redis
    image: redis:alpine
EOF

# 4. Pod Ready 대기
kubectl -n "$NAMESPACE" wait --for=condition=Ready pod --all --timeout=60s || true

# 5. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/067"
