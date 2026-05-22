#!/bin/bash
# Problem 060: Pod에서 K8s API 호출
# Domain: Cluster Architecture, Installation & Configuration
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q060"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. ServiceAccount 생성
kubectl -n "$NAMESPACE" create serviceaccount api-reader || fail_with_cleanup "$NAMESPACE" "ServiceAccount 생성 실패"

# 4. Role 및 RoleBinding 생성 (secrets list 권한)
kubectl -n "$NAMESPACE" apply -f - <<EOF || fail_with_cleanup "$NAMESPACE" "RBAC 리소스 생성 실패"
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: secret-reader
  namespace: ${NAMESPACE}
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["list", "get"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: api-reader-binding
  namespace: ${NAMESPACE}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: secret-reader
subjects:
- kind: ServiceAccount
  name: api-reader
  namespace: ${NAMESPACE}
EOF

# 5. 테스트용 Secret 생성
kubectl -n "$NAMESPACE" create secret generic test-secret --from-literal=password=mysecretvalue || true

# 6. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/060"
