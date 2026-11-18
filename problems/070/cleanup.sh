#!/bin/bash
# Problem 070: 환경 정리
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

check_cluster

echo -e "${YELLOW}[INFO] Problem 070 환경 정리 시작...${NC}"

# 임시 파일 삭제
rm -rf /tmp/cka-q070 2>/dev/null && \
  echo -e "${GREEN}[OK] /tmp/cka-q070 디렉토리 삭제됨${NC}" || true

# 네임스페이스(cka-q070*)와 그 PV, 아래 클러스터 리소스를 한 번에 정리
cleanup_problem 070 || exit 1

echo -e "${GREEN}[완료] Problem 070 환경 정리 완료${NC}"
