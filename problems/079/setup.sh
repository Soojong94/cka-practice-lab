#!/bin/bash
# Problem 079: API Server 감사 로깅
# Domain: Cluster Architecture, Installation & Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q079"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. 불완전한 감사 정책 템플릿 ConfigMap 생성
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "리소스 생성 실패"
apiVersion: v1
kind: ConfigMap
metadata:
  name: audit-policy
  namespace: $NAMESPACE
data:
  policy.yaml: |
    apiVersion: audit.k8s.io/v1
    kind: Policy
    rules:
    # Rule 1: TODO - Secrets에 대한 모든 요청을 기록
    - level: "__LEVEL_1__"
      resources:
      - group: ""
        resources: ["__RESOURCE_1__"]
    # Rule 2: TODO - Namespace 변경을 기록
    - level: "__LEVEL_2__"
      resources:
      - group: ""
        resources: ["__RESOURCE_2__"]
      verbs: ["__VERB_1__", "__VERB_2__", "__VERB_3__"]
    # Rule 3: TODO - ConfigMap 읽기를 무시
    - level: "__LEVEL_3__"
      resources:
      - group: ""
        resources: ["__RESOURCE_3__"]
      verbs: ["__VERB_4__", "__VERB_5__", "__VERB_6__"]
EOF

# 4. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/079"
