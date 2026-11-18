#!/bin/bash
# Problem 095: 환경 정리
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q095"

check_cluster

echo -e "${YELLOW}[INFO] Problem 095 환경 정리 시작...${NC}"

# CoreDNS 원본 설정 복원 (setup에서 백업한 Corefile)
coredns_restore

# 네임스페이스(cka-q095*)와 그 PV, 아래 클러스터 리소스를 한 번에 정리
cleanup_problem 095 || exit 1

echo -e "${GREEN}[완료] Problem 095 환경 정리 완료${NC}"
