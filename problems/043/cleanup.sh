#!/bin/bash
# Problem 043: 환경 정리
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

check_cluster

echo -e "${YELLOW}[INFO] Problem 043 환경 정리 시작...${NC}"

# 노드 레이블 제거
kubectl label nodes --all gpu- 2>/dev/null || true

# 네임스페이스(cka-q043*)와 그 PV, 아래 클러스터 리소스를 한 번에 정리
cleanup_problem 043 || exit 1

echo -e "${GREEN}[완료] Problem 043 환경 정리 완료${NC}"
