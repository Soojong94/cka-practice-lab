#!/bin/bash
# Problem 066: 환경 정리
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

check_cluster

echo -e "${YELLOW}[INFO] Problem 066 환경 정리 시작...${NC}"

# 노드 uncordon (안전을 위해)
kubectl uncordon docker-desktop 2>/dev/null && \
  echo -e "${GREEN}[OK] 노드 'docker-desktop' uncordon됨${NC}" || true

# 네임스페이스(cka-q066*)와 그 PV, 아래 클러스터 리소스를 한 번에 정리
cleanup_problem 066 || exit 1

echo -e "${GREEN}[완료] Problem 066 환경 정리 완료${NC}"
