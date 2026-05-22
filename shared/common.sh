#!/bin/bash
# CKA Practice Lab - 공통 함수
# 모든 스크립트에서 source로 로드하여 사용

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 클러스터 연결 확인
check_cluster() {
  if ! kubectl cluster-info &>/dev/null; then
    echo -e "${RED}[ERROR] 쿠버네티스 클러스터에 연결할 수 없습니다.${NC}" >&2
    echo "Docker Desktop에서 Kubernetes를 활성화하세요:" >&2
    echo "  Settings > Kubernetes > Enable Kubernetes" >&2
    exit 1
  fi
}

# 네임스페이스 초기화 (멱등성 보장)
init_namespace() {
  local ns=$1
  if kubectl get namespace "$ns" &>/dev/null; then
    echo -e "${YELLOW}[INFO] 기존 네임스페이스 '$ns' 삭제 중...${NC}"
    kubectl delete namespace "$ns" --grace-period=0 --force 2>/dev/null
    # 삭제 완료 대기 (최대 30초)
    local count=0
    while kubectl get namespace "$ns" &>/dev/null && [ $count -lt 30 ]; do
      sleep 1
      count=$((count+1))
    done
  fi
  kubectl create namespace "$ns"
  echo -e "${GREEN}[OK] 네임스페이스 '$ns' 생성 완료${NC}"
}

# 리소스 생성 실패 시 정리 후 종료
fail_with_cleanup() {
  local ns=$1
  local msg=$2
  echo -e "${RED}[ERROR] $msg${NC}" >&2
  if [ -n "$ns" ]; then
    echo -e "${YELLOW}[INFO] 네임스페이스 '$ns' 정리 중...${NC}" >&2
    kubectl delete namespace "$ns" --ignore-not-found --wait=false 2>/dev/null
  fi
  exit 1
}

# 검증 결과 출력
print_pass() {
  echo -e "${GREEN}[PASS]${NC} $1"
}

print_fail() {
  echo -e "${RED}[FAIL]${NC} $1"
  if [ -n "$2" ]; then
    echo -e "  ${YELLOW}Hint:${NC} $2"
  fi
}

# 최종 점수 출력
print_score() {
  local pass=$1
  local total=$2
  local percent=$((pass * 100 / total))
  echo ""
  echo "========================================="
  if [ $pass -eq $total ]; then
    echo -e "${GREEN}Score: $pass/$total ($percent%) - 모든 작업 통과!${NC}"
  else
    echo -e "${YELLOW}Score: $pass/$total ($percent%)${NC}"
  fi
  echo "========================================="
}

# 셋업 완료 메시지
print_setup_complete() {
  local ns=$1
  local problem_dir=$2
  echo ""
  echo -e "${BLUE}=========================================${NC}"
  echo -e "${GREEN} 환경 세팅 완료!${NC}"
  echo -e "${BLUE}=========================================${NC}"
  echo -e " 네임스페이스: ${YELLOW}$ns${NC}"
  echo " 생성된 리소스:"
  kubectl -n "$ns" get all 2>/dev/null
  echo ""
  echo -e " 문제를 확인하세요: ${YELLOW}$problem_dir/problem.md${NC}"
  echo -e "${BLUE}=========================================${NC}"
}
