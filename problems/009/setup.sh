#!/bin/bash
# Problem 009: projected Volume (여러 소스 결합)
# Domain: Configuration
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q009"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. ServiceAccount 생성
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "ServiceAccount 생성 실패"
apiVersion: v1
kind: ServiceAccount
metadata:
  name: app-sa
EOF

# 4. ConfigMap 생성
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "ConfigMap 생성 실패"
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  app.properties: |
    app.name=projected-demo
    app.version=1.0.0
    app.env=production
EOF

# 5. Secret 생성
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "Secret 생성 실패"
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
type: Opaque
stringData:
  api-key: "k8s-projected-secret-key-2024"
EOF

# 6. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/009"
