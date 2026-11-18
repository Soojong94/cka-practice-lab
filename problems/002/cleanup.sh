#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q002"
check_cluster

echo -e "${YELLOW}[INFO] Problem 002 환경 정리 시작...${NC}"

kubectl delete sc local-backup --ignore-not-found --wait=false 2>/dev/null && \
  echo -e "${GREEN}[OK] StorageClass 'local-backup' 삭제됨${NC}" || true

if kubectl get namespace "$NAMESPACE" &>/dev/null; then
  kubectl delete namespace "$NAMESPACE" --grace-period=0 --force 2>/dev/null && \
    echo -e "${GREEN}[OK] 네임스페이스 '$NAMESPACE' 삭제 요청됨${NC}" || true
fi

echo -e "${GREEN}[완료] Problem 002 환경 정리 완료${NC}"
