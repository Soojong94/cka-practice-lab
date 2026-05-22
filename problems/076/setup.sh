#!/bin/bash
# Problem 076: CNI 플러그인 확인 및 설정
# Domain: Cluster Architecture, Installation & Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q076"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. 답안 작성용 ConfigMap 생성
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "리소스 생성 실패"
apiVersion: v1
kind: ConfigMap
metadata:
  name: cni-info
  namespace: $NAMESPACE
data:
  cni-plugin: "# TODO: 사용 중인 CNI 플러그인 이름을 기록하세요"
  config-path: "# TODO: CNI 설정 파일 경로를 기록하세요"
  pod-cidr: "# TODO: Pod CIDR을 기록하세요"
EOF

# 4. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/076"
