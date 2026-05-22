#!/bin/bash
# Problem 058: ClusterRole/ClusterRoleBinding
# Domain: Cluster Architecture, Installation & Configuration
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q058"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. ServiceAccount 생성
kubectl -n "$NAMESPACE" create serviceaccount cluster-viewer || fail_with_cleanup "$NAMESPACE" "ServiceAccount 생성 실패"

# 4. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/058"
