#!/bin/bash
# Problem 061: 환경 정리
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

check_cluster

echo -e "${YELLOW}[INFO] Problem 061 환경 정리 시작...${NC}"

# 노드 uncordon (drain 명령을 실제로 실행했을 경우 대비)
NODE_NAME=$(control_plane_node)
kubectl uncordon "$NODE_NAME" >/dev/null 2>&1 && \
  echo -e "${GREEN}[OK] 노드 '$NODE_NAME' uncordon됨${NC}" || true

# 네임스페이스(cka-q061*)와 그 PV, 아래 클러스터 리소스를 한 번에 정리
cleanup_problem 061 || exit 1

echo -e "${GREEN}[완료] Problem 061 환경 정리 완료${NC}"
