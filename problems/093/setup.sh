#!/bin/bash
# Problem 093: Service ExternalName 구성
# Domain: Services & Networking
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q093"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. 빈 네임스페이스 (문제에서 직접 리소스 생성)
echo -e "${YELLOW}[INFO] 빈 네임스페이스 준비 완료${NC}"

# 4. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/093"
