#!/bin/bash
# CKA Practice Lab - 공통 함수
# 모든 스크립트에서 source로 로드하여 사용

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Windows Git Bash 대응: kubectl(Windows 프로그램)에 넘기는 리눅스 경로를 변환하지 않음
# 예) kubectl exec pod -- cat /etc/secrets/x 가 C:/Program Files/Git/etc/secrets/x 로 바뀌는 문제
# openssl -subj "/CN=..." 도 경로로 오인되므로 제외
# /tmp는 로컬 파일(kubeconfig 등)을 가리키므로 기존대로 변환
export MSYS2_ARG_CONV_EXCL="/CN=;/etc;/var;/usr;/opt;/srv;/run;/proc;/sys;/dev;/root;/home;/shared;/data;/mnt;/app;/config;/logs"

# 학생이 Git Bash에서 입력해 Windows 경로로 바뀐 값을 리눅스 경로로 되돌림
# 예) C:/Program Files/Git/etc/kubernetes/pki/ca.crt → /etc/kubernetes/pki/ca.crt
unmangle_path() {
  printf '%s' "$1" | sed -E 's#^[A-Za-z]:/Program Files/Git##'
}

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

# 실습용 노드 선택
# - Docker Desktop 기본(단일 노드): docker-desktop
# - kind 등 멀티 노드: control-plane이 아닌 워커 노드
# 일반 Pod가 스케줄될 수 있는 노드 목록 (이름순)
lab_nodes() {
  local nodes
  nodes=$(kubectl get nodes -l '!node-role.kubernetes.io/control-plane' \
    -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' 2>/dev/null | sort)
  [ -z "$nodes" ] && nodes=$(kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' 2>/dev/null | sort)
  echo "$nodes"
}
# 문제에서 사용할 대표 노드 1개 (setup/validate/cleanup에서 항상 같은 노드)
lab_node() {
  lab_nodes | head -1
}
# control-plane 노드 이름 (단일 노드면 그 노드)
control_plane_node() {
  local n
  n=$(kubectl get nodes -l 'node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
  [ -z "$n" ] && n=$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
  echo "$n"
}

# ---------------------------------------------------------------
# CoreDNS 백업/복원 (CoreDNS를 건드리는 문제 018, 095에서 사용)
# 원본 Corefile을 파일로 백업하고, cleanup 때 그대로 되돌림.
# 이미 깨진 설정(중괄호 불일치)은 백업하지 않아 원본 백업을 덮어쓰지 않음.
# ---------------------------------------------------------------
COREDNS_BACKUP_FILE="/tmp/cka-coredns-Corefile"

_corefile_ok() {
  [ -n "$1" ] && [ "$(printf '%s' "$1" | tr -cd '{' | wc -c)" = "$(printf '%s' "$1" | tr -cd '}' | wc -c)" ]
}

coredns_backup() {
  local cur
  cur=$(kubectl -n kube-system get configmap coredns -o jsonpath='{.data.Corefile}' 2>/dev/null)
  if _corefile_ok "$cur"; then
    printf '%s\n' "$cur" > "$COREDNS_BACKUP_FILE"
    echo -e "${GREEN}[OK] CoreDNS 원본 설정 백업: $COREDNS_BACKUP_FILE${NC}"
  elif [ -f "$COREDNS_BACKUP_FILE" ]; then
    echo -e "${YELLOW}[INFO] 현재 CoreDNS 설정이 이미 깨져 있어 기존 백업을 유지합니다${NC}"
  else
    echo -e "${RED}[ERROR] CoreDNS 설정을 백업할 수 없습니다 (현재 설정이 비정상)${NC}" >&2
    return 1
  fi
}

# Corefile 내용을 kube-system/coredns에 반영 (resourceVersion 충돌 없이 교체)
coredns_apply() {
  kubectl -n kube-system create configmap coredns --from-literal=Corefile="$1" \
    --dry-run=client -o yaml | kubectl replace -f - >/dev/null
}

coredns_restore() {
  if [ ! -f "$COREDNS_BACKUP_FILE" ]; then
    echo -e "${YELLOW}[INFO] CoreDNS 백업 없음 (복원 생략)${NC}"
    return 0
  fi
  echo -e "${YELLOW}[INFO] CoreDNS 원본 설정 복원 중...${NC}"
  if ! coredns_apply "$(cat "$COREDNS_BACKUP_FILE")"; then
    echo -e "${RED}[WARN] CoreDNS ConfigMap 복원 실패. 백업 파일: $COREDNS_BACKUP_FILE${NC}" >&2
    return 1
  fi
  kubectl -n kube-system rollout restart deployment coredns >/dev/null 2>&1
  if kubectl -n kube-system rollout status deployment coredns --timeout=90s >/dev/null 2>&1; then
    rm -f "$COREDNS_BACKUP_FILE"
    echo -e "${GREEN}[OK] CoreDNS 원본 설정 복원 및 재시작 완료${NC}"
  else
    echo -e "${RED}[WARN] CoreDNS 설정은 복원했지만 Pod가 아직 Ready가 아닙니다${NC}" >&2
    echo "  kubectl -n kube-system get pods -l k8s-app=kube-dns 로 확인하세요." >&2
    return 1
  fi
}

# ---------------------------------------------------------------
# 스토리지: 클러스터에 있는 동적 provisioner 사용
# Docker Desktop(kubeadm): docker.io/hostpath, kind: rancher.io/local-path
# ---------------------------------------------------------------
storage_provisioner() {
  local p
  p=$(kubectl get storageclass hostpath -o jsonpath='{.provisioner}' 2>/dev/null)
  [ -z "$p" ] && p=$(kubectl get storageclass -o jsonpath='{range .items[?(@.metadata.annotations.storageclass\.kubernetes\.io/is-default-class=="true")]}{.provisioner}{"\n"}{end}' 2>/dev/null | head -1)
  echo "${p:-docker.io/hostpath}"
}

# local-path provisioner는 Immediate 바인딩을 지원하지 않음
storage_binding_mode() {
  if [ "$(storage_provisioner)" = "rancher.io/local-path" ]; then
    echo "WaitForFirstConsumer"
  else
    echo "Immediate"
  fi
}

# 클러스터 안에서 일회성 명령을 실행하고 출력을 돌려줌
# (kubectl run --rm -i 는 Windows Git Bash에서 출력이 비어 오므로 사용하지 않음)
# 사용법: run_in_pod <namespace> <pod-name> <image> <command> [args...]
run_in_pod() {
  local ns=$1 name=$2 image=$3 i phase
  shift 3
  kubectl -n "$ns" delete pod "$name" --ignore-not-found --now >/dev/null 2>&1
  kubectl -n "$ns" run "$name" --image="$image" --restart=Never --command -- "$@" >/dev/null 2>&1 || return 1
  for ((i = 0; i < 60; i++)); do
    phase=$(kubectl -n "$ns" get pod "$name" -o jsonpath='{.status.phase}' 2>/dev/null)
    [[ $phase == Succeeded || $phase == Failed ]] && break
    sleep 1
  done
  kubectl -n "$ns" logs "$name" 2>/dev/null
  kubectl -n "$ns" delete pod "$name" --now --wait=false >/dev/null 2>&1
}
