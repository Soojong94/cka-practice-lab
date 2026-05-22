#!/bin/bash
# Problem 096: 환경 정리
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NS_A="cka-q096-a"
NS_B="cka-q096-b"

check_cluster

echo -e "${YELLOW}[INFO] Problem 096 환경 정리 시작...${NC}"

for NS in "$NS_A" "$NS_B"; do
  if kubectl get namespace "$NS" &>/dev/null; then
    kubectl delete namespace "$NS" --grace-period=0 --force 2>/dev/null && \
      echo -e "${GREEN}[OK] 네임스페이스 '$NS' 삭제 요청됨${NC}" || \
      echo -e "${RED}[WARN] 네임스페이스 '$NS' 삭제 실패${NC}" >&2
  else
    echo -e "${YELLOW}[INFO] 네임스페이스 '$NS' 이미 없음${NC}"
  fi
done

echo -e "${GREEN}[완료] Problem 096 환경 정리 완료${NC}"
