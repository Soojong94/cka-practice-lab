#!/bin/bash
# Problem 044: 환경 정리
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

check_cluster

echo -e "${YELLOW}[INFO] Problem 044 환경 정리 시작...${NC}"

# 노드 taint 제거 (남아있을 수 있으므로)
kubectl taint nodes --all env=production:NoSchedule- 2>/dev/null || true

# 네임스페이스(cka-q044*)와 그 PV, 아래 클러스터 리소스를 한 번에 정리
cleanup_problem 044 || exit 1

echo -e "${GREEN}[완료] Problem 044 환경 정리 완료${NC}"
