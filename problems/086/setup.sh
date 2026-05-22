#!/bin/bash
# Problem 086: NetworkPolicy Egress 규칙
# Domain: Services & Networking
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q086"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. app Pod와 db Pod 생성
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "리소스 생성 실패"
apiVersion: v1
kind: Pod
metadata:
  name: app
  labels:
    role: app
spec:
  containers:
  - name: curl
    image: curlimages/curl:latest
    command: ["sleep", "3600"]
---
apiVersion: v1
kind: Pod
metadata:
  name: db
  labels:
    role: db
spec:
  containers:
  - name: postgres
    image: busybox:1.36
    command: ["sh", "-c", "while true; do nc -l -p 5432 -e echo connected; done"]
    ports:
    - containerPort: 5432
EOF

# 4. 리소스 Ready 대기
kubectl -n "$NAMESPACE" wait --for=condition=Ready pod/app --timeout=60s || true
kubectl -n "$NAMESPACE" wait --for=condition=Ready pod/db --timeout=60s || true

# 5. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/086"
