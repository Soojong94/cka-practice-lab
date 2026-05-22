#!/bin/bash
# Problem 031: RBAC 권한 부족 디버깅
# Domain: Troubleshooting
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q031"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. ServiceAccount 생성
kubectl -n "$NAMESPACE" create serviceaccount app-sa || fail_with_cleanup "$NAMESPACE" "ServiceAccount 생성 실패"

# 4. 불완전한 Role 생성 (pods get만 허용, list/configmaps 누락)
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "Role 생성 실패"
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: app-role
  namespace: $NAMESPACE
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get"]
EOF

# 5. RoleBinding 생성
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "RoleBinding 생성 실패"
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: app-rolebinding
  namespace: $NAMESPACE
subjects:
- kind: ServiceAccount
  name: app-sa
  namespace: $NAMESPACE
roleRef:
  kind: Role
  name: app-role
  apiGroup: rbac.authorization.k8s.io
EOF

# 6. ServiceAccount를 사용하는 Pod 생성
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "Pod 생성 실패"
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
  namespace: $NAMESPACE
spec:
  serviceAccountName: app-sa
  containers:
  - name: app
    image: busybox:1.36
    command: ["sleep", "3600"]
EOF

# 7. Pod Ready 대기
kubectl -n "$NAMESPACE" wait --for=condition=Ready pod/app-pod --timeout=60s || true

# 8. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/031"
