#!/bin/bash
# Problem 068: 환경 정리
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q068"

check_cluster

echo -e "${YELLOW}[INFO] Problem 068 환경 정리 시작...${NC}"

# 추가 네임스페이스 삭제
for ns in "$NAMESPACE" "cka-q068-team-a" "cka-q068-team-b"; do
  if kubectl get namespace "$ns" &>/dev/null; then
    kubectl delete namespace "$ns" --grace-period=0 --force 2>/dev/null && \
      echo -e "${GREEN}[OK] 네임스페이스 '$ns' 삭제 요청됨${NC}" || \
      echo -e "${RED}[WARN] 네임스페이스 '$ns' 삭제 실패${NC}" >&2
  else
    echo -e "${YELLOW}[INFO] 네임스페이스 '$ns' 이미 없음${NC}"
  fi
done

echo -e "${GREEN}[완료] Problem 068 환경 정리 완료${NC}"
