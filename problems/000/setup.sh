#!/bin/bash
# Problem 000: 환경 설정 확인
# 이 스크립트는 CKA Practice Lab 실행에 필요한 환경을 검증합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE} CKA Practice Lab - 환경 검증${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""

PASS=0
TOTAL=0

# 1. kubectl 확인
TOTAL=$((TOTAL+1))
if command -v kubectl &>/dev/null; then
  KVER=$(kubectl version --client -o json 2>/dev/null | grep -o '"gitVersion":"[^"]*"' | head -1)
  echo -e "${GREEN}[OK]${NC} kubectl 설치됨 ($KVER)"
  PASS=$((PASS+1))
else
  echo -e "${RED}[FAIL]${NC} kubectl 미설치"
fi

# 2. 클러스터 연결
TOTAL=$((TOTAL+1))
if kubectl cluster-info &>/dev/null; then
  echo -e "${GREEN}[OK]${NC} 쿠버네티스 클러스터 연결됨"
  PASS=$((PASS+1))
else
  echo -e "${RED}[FAIL]${NC} 클러스터 연결 실패 - Docker Desktop Kubernetes 활성화 필요"
fi

# 3. 노드 상태
TOTAL=$((TOTAL+1))
NODE_STATUS=$(kubectl get nodes -o jsonpath='{.items[0].status.conditions[?(@.type=="Ready")].status}' 2>/dev/null)
if [ "$NODE_STATUS" = "True" ]; then
  NODE_NAME=$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
  echo -e "${GREEN}[OK]${NC} 노드 '$NODE_NAME' Ready 상태"
  PASS=$((PASS+1))
else
  echo -e "${RED}[FAIL]${NC} 노드가 Ready 상태가 아님"
fi

# 4. 시스템 Pod 확인
TOTAL=$((TOTAL+1))
SYSTEM_PODS=$(kubectl get pods -n kube-system --field-selector=status.phase=Running --no-headers 2>/dev/null | wc -l)
if [ "$SYSTEM_PODS" -ge 5 ]; then
  echo -e "${GREEN}[OK]${NC} 시스템 Pod $SYSTEM_PODS개 Running"
  PASS=$((PASS+1))
else
  echo -e "${RED}[FAIL]${NC} 시스템 Pod 부족 (현재: $SYSTEM_PODS개)"
fi

# 5. context 확인
TOTAL=$((TOTAL+1))
CTX=$(kubectl config current-context 2>/dev/null)
if [ "$CTX" = "docker-desktop" ]; then
  echo -e "${GREEN}[OK]${NC} context: docker-desktop"
  PASS=$((PASS+1))
else
  echo -e "${YELLOW}[WARN]${NC} context: $CTX (docker-desktop 권장)"
  PASS=$((PASS+1))  # 다른 context도 허용
fi

echo ""
echo -e "${BLUE}=========================================${NC}"
if [ $PASS -eq $TOTAL ]; then
  echo -e "${GREEN} 모든 환경 검증 통과! ($PASS/$TOTAL)${NC}"
  echo -e "${GREEN} CKA Practice Lab을 시작할 준비가 되었습니다.${NC}"
else
  echo -e "${YELLOW} 일부 항목 실패 ($PASS/$TOTAL)${NC}"
  echo -e "${YELLOW} 위의 [FAIL] 항목을 해결한 후 다시 실행하세요.${NC}"
fi
echo -e "${BLUE}=========================================${NC}"
