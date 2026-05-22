#!/bin/bash
# Problem 088: Gateway API - GatewayClass/Gateway 구성
# Domain: Services & Networking
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q088"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. Gateway API CRDs 설치 (없는 경우)
echo -e "${YELLOW}[INFO] Gateway API CRDs 설치 확인 중...${NC}"
if ! kubectl get crd gateways.gateway.networking.k8s.io &>/dev/null; then
  echo -e "${YELLOW}[INFO] Gateway API CRDs 설치 중...${NC}"
  kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml 2>/dev/null || \
    echo -e "${YELLOW}[WARN] Gateway API CRDs 설치 실패 - 오프라인 환경일 수 있음${NC}"
fi

# 4. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/088"
