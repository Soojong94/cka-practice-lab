#!/bin/bash
# Problem 046: 환경 정리
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

check_cluster

echo -e "${YELLOW}[INFO] Problem 046 환경 정리 시작...${NC}"

# kustomize 디렉토리 삭제
rm -rf /tmp/kustomize 2>/dev/null && \
  echo -e "${GREEN}[OK] /tmp/kustomize 디렉토리 삭제됨${NC}" || true

# 네임스페이스(cka-q046*)와 그 PV, 아래 클러스터 리소스를 한 번에 정리
cleanup_problem 046 || exit 1

echo -e "${GREEN}[완료] Problem 046 환경 정리 완료${NC}"
