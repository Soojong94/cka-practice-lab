#!/bin/bash
# Problem 018: 환경 정리
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q018"

check_cluster

echo -e "${YELLOW}[INFO] Problem 018 환경 정리 시작...${NC}"

# CoreDNS 원본 설정 복원
if [ -f /tmp/coredns-backup.yaml ]; then
  echo -e "${YELLOW}[INFO] CoreDNS 원본 설정 복원 중...${NC}"
  kubectl apply -f /tmp/coredns-backup.yaml 2>/dev/null
  kubectl -n kube-system rollout restart deployment coredns 2>/dev/null
  echo -e "${GREEN}[OK] CoreDNS 설정 복원됨${NC}"
fi

# 네임스페이스 삭제
if kubectl get namespace "$NAMESPACE" &>/dev/null; then
  kubectl delete namespace "$NAMESPACE" --grace-period=0 --force 2>/dev/null && \
    echo -e "${GREEN}[OK] 네임스페이스 '$NAMESPACE' 삭제 요청됨${NC}" || \
    echo -e "${RED}[WARN] 네임스페이스 '$NAMESPACE' 삭제 실패${NC}" >&2
else
  echo -e "${YELLOW}[INFO] 네임스페이스 '$NAMESPACE' 이미 없음${NC}"
fi

echo -e "${GREEN}[완료] Problem 018 환경 정리 완료${NC}"
