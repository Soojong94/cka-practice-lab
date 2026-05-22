#!/bin/bash
# Problem 057: RBAC Role/RoleBinding 생성
# Domain: Cluster Architecture, Installation & Configuration
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q057"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. ServiceAccount 생성
kubectl -n "$NAMESPACE" create serviceaccount developer || fail_with_cleanup "$NAMESPACE" "ServiceAccount 생성 실패"

# 4. 테스트용 리소스 생성
kubectl -n "$NAMESPACE" apply -f - <<EOF || fail_with_cleanup "$NAMESPACE" "리소스 생성 실패"
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
  labels:
    app: test
spec:
  containers:
  - name: nginx
    image: nginx:alpine
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: test-config
data:
  key: value
EOF

kubectl -n "$NAMESPACE" wait --for=condition=Ready pod/test-pod --timeout=60s || true

# 5. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/057"
