#!/bin/bash
# Problem 068: Namespace 관리 및 리소스 격리
# Domain: Cluster Architecture, Installation & Configuration
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q068"

# 1. 클러스터 연결 확인
check_cluster

# 2. 메인 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. team-a, team-b 네임스페이스 생성
kubectl delete namespace cka-q068-team-a --ignore-not-found --grace-period=0 --force 2>/dev/null || true
kubectl delete namespace cka-q068-team-b --ignore-not-found --grace-period=0 --force 2>/dev/null || true
sleep 3

kubectl create namespace cka-q068-team-a || fail_with_cleanup "$NAMESPACE" "team-a 네임스페이스 생성 실패"
kubectl create namespace cka-q068-team-b || fail_with_cleanup "$NAMESPACE" "team-b 네임스페이스 생성 실패"

echo -e "${GREEN}[OK] 네임스페이스 'cka-q068-team-a', 'cka-q068-team-b' 생성 완료${NC}"

# 4. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/068"
echo -e "${YELLOW}[INFO] 추가 네임스페이스: cka-q068-team-a, cka-q068-team-b${NC}"
