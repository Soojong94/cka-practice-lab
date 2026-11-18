#!/bin/bash
# Problem 010: 환경 정리
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q010"

check_cluster

echo -e "${YELLOW}[INFO] Problem 010 환경 정리 시작...${NC}"

# 클러스터 범위 리소스 삭제
kubectl delete pv debug-pv --ignore-not-found --wait=false 2>/dev/null && \
  echo -e "${GREEN}[OK] PV 'debug-pv' 삭제됨${NC}" || true

# 네임스페이스 삭제 (네임스페이스 내 모든 리소스 일괄 제거)
if kubectl get namespace "$NAMESPACE" &>/dev/null; then
  kubectl delete namespace "$NAMESPACE" --grace-period=0 --force 2>/dev/null && \
    echo -e "${GREEN}[OK] 네임스페이스 '$NAMESPACE' 삭제 요청됨${NC}" || \
    echo -e "${RED}[WARN] 네임스페이스 '$NAMESPACE' 삭제 실패${NC}" >&2
else
  echo -e "${YELLOW}[INFO] 네임스페이스 '$NAMESPACE' 이미 없음${NC}"
fi

echo -e "${GREEN}[완료] Problem 010 환경 정리 완료${NC}"
