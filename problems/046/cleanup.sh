#!/bin/bash
# Problem 046: 환경 정리
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE_STAGING="cka-q046-staging"
NAMESPACE_PROD="cka-q046-prod"

check_cluster

echo -e "${YELLOW}[INFO] Problem 046 환경 정리 시작...${NC}"

# kustomize 디렉토리 삭제
rm -rf /tmp/kustomize 2>/dev/null && \
  echo -e "${GREEN}[OK] /tmp/kustomize 디렉토리 삭제됨${NC}" || true

# 네임스페이스 삭제
for NS in "$NAMESPACE_STAGING" "$NAMESPACE_PROD"; do
  if kubectl get namespace "$NS" &>/dev/null; then
    kubectl delete namespace "$NS" --grace-period=0 --force 2>/dev/null && \
      echo -e "${GREEN}[OK] 네임스페이스 '$NS' 삭제 요청됨${NC}" || \
      echo -e "${RED}[WARN] 네임스페이스 '$NS' 삭제 실패${NC}" >&2
  else
    echo -e "${YELLOW}[INFO] 네임스페이스 '$NS' 이미 없음${NC}"
  fi
done

echo -e "${GREEN}[완료] Problem 046 환경 정리 완료${NC}"
