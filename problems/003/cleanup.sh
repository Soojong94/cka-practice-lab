#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q003"
check_cluster

echo -e "${YELLOW}[INFO] Problem 003 환경 정리 시작...${NC}"
kubectl delete pv cka-q003-data-pv --ignore-not-found 2>/dev/null && \
  echo -e "${GREEN}[OK] PV 삭제됨${NC}" || true
if kubectl get namespace "$NAMESPACE" &>/dev/null; then
  kubectl delete namespace "$NAMESPACE" --grace-period=0 --force 2>/dev/null && \
    echo -e "${GREEN}[OK] 네임스페이스 삭제 요청됨${NC}" || true
fi
echo -e "${GREEN}[완료] Problem 003 환경 정리 완료${NC}"
