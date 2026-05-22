#!/bin/bash
# Problem 064: 환경 정리
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q064"

check_cluster

echo -e "${YELLOW}[INFO] Problem 064 환경 정리 시작...${NC}"

# CRD 삭제 (CR도 함께 삭제됨)
kubectl delete crd databases.stable.example.com --ignore-not-found 2>/dev/null && \
  echo -e "${GREEN}[OK] CRD 'databases.stable.example.com' 삭제됨${NC}" || true

# 네임스페이스 삭제
if kubectl get namespace "$NAMESPACE" &>/dev/null; then
  kubectl delete namespace "$NAMESPACE" --grace-period=0 --force 2>/dev/null && \
    echo -e "${GREEN}[OK] 네임스페이스 '$NAMESPACE' 삭제 요청됨${NC}" || \
    echo -e "${RED}[WARN] 네임스페이스 '$NAMESPACE' 삭제 실패${NC}" >&2
else
  echo -e "${YELLOW}[INFO] 네임스페이스 '$NAMESPACE' 이미 없음${NC}"
fi

echo -e "${GREEN}[완료] Problem 064 환경 정리 완료${NC}"
