#!/bin/bash
# Problem 062: 환경 정리
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q062"

check_cluster

echo -e "${YELLOW}[INFO] Problem 062 환경 정리 시작...${NC}"

# Helm 릴리스 삭제
helm uninstall web-release -n "$NAMESPACE" 2>/dev/null && \
  echo -e "${GREEN}[OK] Helm 릴리스 'web-release' 삭제됨${NC}" || true

# 네임스페이스(cka-q062*)와 그 PV, 아래 클러스터 리소스를 한 번에 정리
cleanup_problem 062 || exit 1

echo -e "${GREEN}[완료] Problem 062 환경 정리 완료${NC}"
