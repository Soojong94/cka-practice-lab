#!/bin/bash
# Problem 038: 환경 정리
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

check_cluster

echo -e "${YELLOW}[INFO] Problem 038 환경 정리 시작...${NC}"

# 노드 taint 제거
NODE_NAME=$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')
kubectl taint nodes "$NODE_NAME" dedicated=special:NoSchedule- 2>/dev/null && \
  echo -e "${GREEN}[OK] 노드 taint 'dedicated=special:NoSchedule' 제거됨${NC}" || true

# 노드 레이블 제거
kubectl label nodes "$NODE_NAME" disk- 2>/dev/null && \
  echo -e "${GREEN}[OK] 노드 레이블 'disk' 제거됨${NC}" || true

# 네임스페이스(cka-q038*)와 그 PV, 아래 클러스터 리소스를 한 번에 정리
cleanup_problem 038 || exit 1

echo -e "${GREEN}[완료] Problem 038 환경 정리 완료${NC}"
