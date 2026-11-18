#!/bin/bash
# Problem 065: 환경 정리
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q065"

check_cluster

echo -e "${YELLOW}[INFO] Problem 065 환경 정리 시작...${NC}"

# 클러스터 범위 리소스 삭제
kubectl delete clusterrolebinding app-controller-binding-q065 --ignore-not-found --wait=false 2>/dev/null || true
kubectl delete clusterrole app-controller-role-q065 --ignore-not-found --wait=false 2>/dev/null || true
kubectl delete crd apps.operator.example.com --ignore-not-found --wait=false 2>/dev/null && \
  echo -e "${GREEN}[OK] CRD 'apps.operator.example.com' 삭제됨${NC}" || true

# 네임스페이스 삭제
if kubectl get namespace "$NAMESPACE" &>/dev/null; then
  kubectl delete namespace "$NAMESPACE" --grace-period=0 --force 2>/dev/null && \
    echo -e "${GREEN}[OK] 네임스페이스 '$NAMESPACE' 삭제 요청됨${NC}" || \
    echo -e "${RED}[WARN] 네임스페이스 '$NAMESPACE' 삭제 실패${NC}" >&2
else
  echo -e "${YELLOW}[INFO] 네임스페이스 '$NAMESPACE' 이미 없음${NC}"
fi

echo -e "${GREEN}[완료] Problem 065 환경 정리 완료${NC}"
