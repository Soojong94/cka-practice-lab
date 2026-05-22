#!/bin/bash
# Problem 044: Taint/Toleration 활용
# Domain: Workloads & Scheduling
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q044"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. 노드에 taint 추가
NODE_NAME=$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')
kubectl taint nodes "$NODE_NAME" env=production:NoSchedule --overwrite 2>/dev/null || true
echo -e "${GREEN}[OK] 노드 '$NODE_NAME'에 taint 'env=production:NoSchedule' 추가됨${NC}"

# 4. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/044"
