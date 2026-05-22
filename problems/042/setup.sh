#!/bin/bash
# Problem 042: Pod Anti-Affinity로 분산 배치
# Domain: Workloads & Scheduling
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q042"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. 노드에 zone 레이블 추가 (시뮬레이션)
NODE_NAME=$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')
kubectl label node "$NODE_NAME" zone=a --overwrite 2>/dev/null || true

# 4. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/042"
