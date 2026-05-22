#!/bin/bash
# Problem 063: Helm 차트 커스터마이징
# Domain: Cluster Architecture, Installation & Configuration
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q063"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. Helm 설치 확인
if ! command -v helm &>/dev/null; then
  echo -e "${RED}[ERROR] Helm이 설치되어 있지 않습니다.${NC}" >&2
  exit 1
fi

# 4. bitnami 리포지토리 확인
helm repo add bitnami https://charts.bitnami.com/bitnami 2>/dev/null || true
helm repo update 2>/dev/null || true

# 5. 기본 값으로 nginx 차트 설치
helm install custom-app bitnami/nginx -n "$NAMESPACE" --wait --timeout 120s 2>/dev/null || \
  helm install custom-app bitnami/nginx -n "$NAMESPACE" 2>/dev/null || \
  fail_with_cleanup "$NAMESPACE" "Helm 차트 설치 실패"

echo -e "${GREEN}[OK] Helm 릴리스 'custom-app' 설치 완료${NC}"

# 6. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/063"
echo -e "${YELLOW}[INFO] 릴리스 'custom-app'을 커스터마이징하세요.${NC}"
