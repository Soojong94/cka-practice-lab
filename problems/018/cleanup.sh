#!/bin/bash
# Problem 018: 환경 정리
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

check_cluster

echo -e "${YELLOW}[INFO] Problem 018 환경 정리 시작...${NC}"

# CoreDNS 원본 설정 복원 (setup에서 백업한 Corefile)
coredns_restore

# 네임스페이스(cka-q018*)와 그 PV, 아래 클러스터 리소스를 한 번에 정리
cleanup_problem 018 || exit 1

echo -e "${GREEN}[완료] Problem 018 환경 정리 완료${NC}"
