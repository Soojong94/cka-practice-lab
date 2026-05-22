#!/bin/bash
# Problem 007: Secret을 Volume + 환경변수로 마운트
# Domain: Configuration
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q007"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. 기본 Pod 생성 (Secret 마운트 없이)
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "Pod 생성 실패"
apiVersion: v1
kind: Pod
metadata:
  name: db-app
  labels:
    app: db-app
spec:
  containers:
  - name: db-app
    image: busybox:1.36
    command: ["sleep", "3600"]
EOF

# 4. 리소스 Ready 대기
kubectl -n "$NAMESPACE" wait --for=condition=Ready pod/db-app --timeout=60s || true

# 5. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/007"
