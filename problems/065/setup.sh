#!/bin/bash
# Problem 065: Operator 설치 및 설정 (시뮬레이션)
# Domain: Cluster Architecture, Installation & Configuration
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q065"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. CRD 생성
kubectl apply -f - <<EOF || fail_with_cleanup "$NAMESPACE" "CRD 생성 실패"
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: apps.operator.example.com
spec:
  group: operator.example.com
  versions:
  - name: v1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            properties:
              appName:
                type: string
              replicas:
                type: integer
              image:
                type: string
  scope: Namespaced
  names:
    plural: apps
    singular: app
    kind: App
EOF

# CRD 등록 대기
sleep 3

# 4. 간단한 컨트롤러 Deployment 생성 (CR 감시 시뮬레이션)
kubectl -n "$NAMESPACE" apply -f - <<EOF || fail_with_cleanup "$NAMESPACE" "컨트롤러 생성 실패"
apiVersion: v1
kind: ServiceAccount
metadata:
  name: app-controller-sa
  namespace: ${NAMESPACE}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: app-controller-role-q065
rules:
- apiGroups: ["operator.example.com"]
  resources: ["apps"]
  verbs: ["get", "list", "watch"]
- apiGroups: [""]
  resources: ["events"]
  verbs: ["create"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: app-controller-binding-q065
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: app-controller-role-q065
subjects:
- kind: ServiceAccount
  name: app-controller-sa
  namespace: ${NAMESPACE}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-controller
  namespace: ${NAMESPACE}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: app-controller
  template:
    metadata:
      labels:
        app: app-controller
    spec:
      serviceAccountName: app-controller-sa
      containers:
      - name: controller
        image: bitnami/kubectl:latest
        command:
        - /bin/sh
        - -c
        - |
          echo "[controller] Starting app-controller..."
          echo "[controller] Watching for App CRs in namespace ${NAMESPACE}..."
          while true; do
            APPS=\$(kubectl get apps.operator.example.com -n ${NAMESPACE} -o jsonpath='{.items[*].metadata.name}' 2>/dev/null)
            if [ -n "\$APPS" ]; then
              for app in \$APPS; do
                echo "[controller] Detected CR: \$app"
              done
            fi
            sleep 5
          done
EOF

# 5. 컨트롤러 Ready 대기
kubectl -n "$NAMESPACE" wait --for=condition=Available deployment/app-controller --timeout=90s || true

# 6. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/065"
