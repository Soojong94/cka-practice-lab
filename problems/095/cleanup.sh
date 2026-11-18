#!/bin/bash
# Problem 095: 환경 정리
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q095"

check_cluster

echo -e "${YELLOW}[INFO] Problem 095 환경 정리 시작...${NC}"

# CoreDNS ConfigMap 복원
BACKUP=$(kubectl -n "$NAMESPACE" get configmap coredns-backup -o jsonpath='{.data.Corefile}' 2>/dev/null)
if [ -n "$BACKUP" ]; then
  kubectl -n kube-system create configmap coredns --from-literal=Corefile="$BACKUP" --dry-run=client -o yaml | \
    kubectl apply -f - 2>/dev/null
  kubectl -n kube-system rollout restart deployment coredns 2>/dev/null || true
  echo -e "${GREEN}[OK] CoreDNS ConfigMap 복원됨${NC}"
fi

# 네임스페이스(cka-q095*)와 그 PV, 아래 클러스터 리소스를 한 번에 정리
cleanup_problem 095 || exit 1

echo -e "${GREEN}[완료] Problem 095 환경 정리 완료${NC}"
