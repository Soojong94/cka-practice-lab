#!/bin/bash
# Problem 039: ServiceAccount 토큰 마운트 문제
# Domain: Troubleshooting
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q039"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. automountServiceAccountToken=false인 ServiceAccount 생성
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "ServiceAccount 생성 실패"
apiVersion: v1
kind: ServiceAccount
metadata:
  name: api-sa
  namespace: $NAMESPACE
automountServiceAccountToken: false
EOF

# 4. 해당 ServiceAccount를 사용하는 Pod 생성 (토큰 마운트 안됨)
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "Pod 생성 실패"
apiVersion: v1
kind: Pod
metadata:
  name: api-pod
  namespace: $NAMESPACE
  labels:
    app: api-pod
spec:
  serviceAccountName: api-sa
  containers:
  - name: kubectl
    image: bitnami/kubectl:latest
    command: ["sleep", "3600"]
EOF

# 5. Pod Ready 대기
kubectl -n "$NAMESPACE" wait --for=condition=Ready pod/api-pod --timeout=60s || true

# 6. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/039"
echo -e "${YELLOW}[INFO] Pod 'api-pod'에 ServiceAccount 토큰이 마운트되지 않았습니다.${NC}"
