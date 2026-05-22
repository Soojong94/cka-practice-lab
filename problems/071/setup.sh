#!/bin/bash
# Problem 071: Admission Controller 이해
# Domain: Cluster Architecture, Installation & Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q071"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. 불완전한 ValidatingWebhookConfiguration 템플릿을 ConfigMap으로 생성
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "리소스 생성 실패"
apiVersion: v1
kind: ConfigMap
metadata:
  name: webhook-config
  namespace: $NAMESPACE
data:
  webhook.yaml: |
    apiVersion: admissionregistration.k8s.io/v1
    kind: ValidatingWebhookConfiguration
    metadata:
      name: pod-validation-webhook
    webhooks:
    - name: validate-pods.example.com
      admissionReviewVersions: ["v1"]
      clientConfig:
        service:
          name: webhook-service
          namespace: webhook-system
          path: "/validate"
        caBundle: LS0tLS1CRUdJTi...
      rules:
      - apiGroups: [""]
        apiVersions: ["v1"]
        operations: ["__OPERATION__"]
        resources: ["__RESOURCE__"]
      failurePolicy: "__FAILURE_POLICY__"
      sideEffects: "__SIDE_EFFECTS__"
      matchPolicy: Equivalent
EOF

# 4. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/071"
