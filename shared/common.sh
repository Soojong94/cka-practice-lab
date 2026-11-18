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

# 문제 환경 정리 (모든 cleanup.sh가 이 함수를 사용)
# 사용법: cleanup_problem <문제번호> [kind/name ...]
#   - cka-q<번호>, cka-<번호>-* 네임스페이스를 자동으로 찾아 삭제
#   - 그 네임스페이스의 PVC에 묶였던 PV는 이름을 몰라도 자동으로 찾아 삭제
#   - 인자로 받은 클러스터 범위 리소스(pv/x, storageclass/y, crd/z ...) 삭제
#   - 삭제 요청은 기다리지 않고 한꺼번에 보낸 뒤, 마지막에 완료 여부를 확인
#     (PV는 PVC가, PVC는 네임스페이스가 지워져야 사라지므로 순서대로 기다리면 멈춤)
#   - CLEANUP_TIMEOUT(기본 60)초가 지나도 남아 있으면 finalizer를 제거해 강제 정리
cleanup_problem() {
  local id=$1; shift
  local ns_re="^cka-q?${id}(-|\$)"
  local timeout=${CLEANUP_TIMEOUT:-60}
  local namespaces pvs targets r ns left i

  namespaces=$(kubectl get namespaces -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' 2>/dev/null | grep -E "$ns_re")
  pvs=$(kubectl get pv -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.spec.claimRef.namespace}{"\n"}{end}' 2>/dev/null \
    | awk -v re="$ns_re" '$2 ~ re {print "persistentvolume/" $1}')
  targets=$(printf '%s\n' "$@" $pvs | awk 'NF && !seen[$0]++')

  # 1) 삭제 요청 (기다리지 않음)
  for r in $targets; do
    kubectl get "$r" &>/dev/null || continue
    kubectl delete "$r" --wait=false >/dev/null 2>&1 && \
      echo -e "${GREEN}[OK] $r 삭제 요청${NC}"
  done
  if [ -z "$namespaces" ]; then
    echo -e "${YELLOW}[INFO] 남아 있는 네임스페이스 없음${NC}"
  fi
  for ns in $namespaces; do
    kubectl -n "$ns" delete pods --all --grace-period=0 --force --wait=false >/dev/null 2>&1
    kubectl delete namespace "$ns" --wait=false >/dev/null 2>&1 && \
      echo -e "${GREEN}[OK] 네임스페이스 '$ns' 삭제 요청${NC}"
  done

  # 2) 완료 대기
  _cleanup_left() {
    local x
    for x in $namespaces; do kubectl get namespace "$x" &>/dev/null && echo "namespace/$x"; done
    for x in $targets; do kubectl get "$x" &>/dev/null && echo "$x"; done
  }
  [ -z "$namespaces$targets" ] && return 0
  echo -e "${YELLOW}[INFO] 삭제 완료 대기 중 (최대 ${timeout}초)...${NC}"
  for ((i = 0; i < timeout; i += 2)); do
    left=$(_cleanup_left)
    [ -z "$left" ] && break
    sleep 2
  done

  # 3) 그래도 남아 있으면 finalizer 제거 후 재확인
  if [ -n "$left" ]; then
    echo -e "${YELLOW}[INFO] 아직 남은 리소스 강제 정리: $(echo $left)${NC}"
    local types obj
    types=$(kubectl api-resources --verbs=list --namespaced -o name 2>/dev/null | paste -sd, -)
    for r in $left; do
      if [[ $r == namespace/* ]]; then
        for obj in $(kubectl -n "${r#namespace/}" get "$types" -o name 2>/dev/null); do
          kubectl -n "${r#namespace/}" patch "$obj" --type=merge -p '{"metadata":{"finalizers":null}}' >/dev/null 2>&1
        done
      else
        kubectl patch "$r" --type=merge -p '{"metadata":{"finalizers":null}}' >/dev/null 2>&1
      fi
    done
    for ((i = 0; i < 20; i += 2)); do
      left=$(_cleanup_left)
      [ -z "$left" ] && break
      sleep 2
    done
  fi

  if [ -n "$left" ]; then
    echo -e "${RED}[WARN] 정리되지 않은 리소스: $(echo $left)${NC}" >&2
    echo "  kubectl get $(echo $left | tr ' ' ',') -o yaml 로 상태를 확인하세요." >&2
    return 1
  fi
  echo -e "${GREEN}[OK] 모든 리소스 삭제 확인${NC}"
}
