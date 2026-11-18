#!/bin/bash
# Problem 038: 환경 정리
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

check_cluster

echo -e "${YELLOW}[INFO] Problem 038 환경 정리 시작...${NC}"

# 모든 노드에서 taint/레이블 제거
kubectl taint nodes --all dedicated=special:NoSchedule- >/dev/null 2>&1
kubectl label nodes --all disk- >/dev/null 2>&1
echo -e "${GREEN}[OK] 노드 taint 'dedicated=special:NoSchedule', 레이블 'disk' 제거됨${NC}"

# 네임스페이스(cka-q038*)와 그 PV, 아래 클러스터 리소스를 한 번에 정리
cleanup_problem 038 || exit 1

echo -e "${GREEN}[완료] Problem 038 환경 정리 완료${NC}"
