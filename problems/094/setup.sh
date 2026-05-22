#!/bin/bash
# Problem 094: Endpoint/EndpointSlice 수동 구성
# Domain: Services & Networking
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q094"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. selector 없는 Service 생성
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "리소스 생성 실패"
apiVersion: v1
kind: Service
metadata:
  name: legacy-svc
spec:
  ports:
  - port: 8080
    targetPort: 8080
EOF

# 4. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/094"
