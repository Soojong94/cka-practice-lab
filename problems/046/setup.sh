#!/bin/bash
# Problem 046: Kustomize로 환경별 배포
# Domain: Workloads & Scheduling
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE_STAGING="cka-q046-staging"
NAMESPACE_PROD="cka-q046-prod"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE_STAGING"
init_namespace "$NAMESPACE_PROD"

# 3. kustomize 디렉토리 구조 생성
rm -rf /tmp/kustomize 2>/dev/null
mkdir -p /tmp/kustomize/base
mkdir -p /tmp/kustomize/overlays/staging
mkdir -p /tmp/kustomize/overlays/prod

echo -e "${GREEN}[OK] Kustomize 디렉토리 구조 생성됨 (/tmp/kustomize/)${NC}"
echo -e "${YELLOW}[INFO] /tmp/kustomize/base/ 에 base 매니페스트를 작성하세요${NC}"
echo -e "${YELLOW}[INFO] /tmp/kustomize/overlays/staging/ 에 staging 오버레이를 작성하세요${NC}"
echo -e "${YELLOW}[INFO] /tmp/kustomize/overlays/prod/ 에 prod 오버레이를 작성하세요${NC}"

# 4. 완료 메시지
echo ""
echo -e "${BLUE}=========================================${NC}"
echo -e "${GREEN} 환경 세팅 완료!${NC}"
echo -e "${BLUE}=========================================${NC}"
echo -e " 네임스페이스: ${YELLOW}$NAMESPACE_STAGING, $NAMESPACE_PROD${NC}"
echo -e " 문제를 확인하세요: ${YELLOW}problems/046/problem.md${NC}"
echo -e "${BLUE}=========================================${NC}"
