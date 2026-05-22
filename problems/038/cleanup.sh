#!/bin/bash
# Problem 038: 환경 정리
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q038"

check_cluster

echo -e "${YELLOW}[INFO] Problem 038 환경 정리 시작...${NC}"

# 노드 taint 제거
NODE_NAME=$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')
kubectl taint nodes "$NODE_NAME" dedicated=special:NoSchedule- 2>/dev/null && \
  echo -e "${GREEN}[OK] 노드 taint 'dedicated=special:NoSchedule' 제거됨${NC}" || true

# 노드 레이블 제거
kubectl label nodes "$NODE_NAME" disk- 2>/dev/null && \
  echo -e "${GREEN}[OK] 노드 레이블 'disk' 제거됨${NC}" || true

# 네임스페이스 삭제 (네임스페이스 내 모든 리소스 일괄 제거)
if kubectl get namespace "$NAMESPACE" &>/dev/null; then
  kubectl delete namespace "$NAMESPACE" --grace-period=0 --force 2>/dev/null && \
    echo -e "${GREEN}[OK] 네임스페이스 '$NAMESPACE' 삭제 요청됨${NC}" || \
    echo -e "${RED}[WARN] 네임스페이스 '$NAMESPACE' 삭제 실패${NC}" >&2
else
  echo -e "${YELLOW}[INFO] 네임스페이스 '$NAMESPACE' 이미 없음${NC}"
fi

echo -e "${GREEN}[완료] Problem 038 환경 정리 완료${NC}"
