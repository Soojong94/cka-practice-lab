#!/bin/bash
# Problem 062: Helm 차트 설치 및 관리
# Domain: Cluster Architecture, Installation & Configuration
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q062"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. Helm 설치 확인
if ! command -v helm &>/dev/null; then
  echo -e "${RED}[ERROR] Helm이 설치되어 있지 않습니다.${NC}" >&2
  echo "Helm 설치: https://helm.sh/docs/intro/install/" >&2
  exit 1
fi

# 4. bitnami 리포지토리 추가
helm repo add bitnami https://charts.bitnami.com/bitnami 2>/dev/null || true
helm repo update 2>/dev/null || true

echo -e "${GREEN}[OK] Helm 및 bitnami 리포지토리 준비 완료${NC}"

# 5. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/062"
echo -e "${YELLOW}[INFO] bitnami/nginx 차트를 설치할 준비가 되었습니다.${NC}"
