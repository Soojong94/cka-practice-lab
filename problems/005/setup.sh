#!/bin/bash
# Problem 005: 다중 접근 모드 PV 구성
# Domain: Storage
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q005"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. 완료 메시지 (이 문제는 빈 네임스페이스에서 시작)
echo -e "${YELLOW}[INFO] 이 문제는 빈 네임스페이스에서 시작합니다.${NC}"
echo -e "${YELLOW}[INFO] PV, PVC, Pod를 직접 생성해야 합니다.${NC}"

print_setup_complete "$NAMESPACE" "problems/005"
