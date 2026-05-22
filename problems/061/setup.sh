#!/bin/bash
# Problem 061: kubeadm 클러스터 업그레이드 시뮬레이션
# Domain: Cluster Architecture, Installation & Configuration
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q061"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. 현재 클러스터 버전 정보 ConfigMap 생성
CURRENT_VERSION=$(kubectl version -o json 2>/dev/null | grep -o '"gitVersion":"[^"]*"' | head -1 | cut -d'"' -f4)
if [ -z "$CURRENT_VERSION" ]; then
  CURRENT_VERSION="v1.28.0"
fi

kubectl -n "$NAMESPACE" apply -f - <<EOF || fail_with_cleanup "$NAMESPACE" "리소스 생성 실패"
apiVersion: v1
kind: ConfigMap
metadata:
  name: cluster-info
  namespace: ${NAMESPACE}
data:
  current-version: "${CURRENT_VERSION}"
  target-version: "v1.29.0"
  node-name: "docker-desktop"
  scenario: |
    현재 클러스터 버전: ${CURRENT_VERSION}
    목표 버전: v1.29.0
    
    시나리오:
    - 단일 노드 클러스터 (control-plane + worker)
    - 업그레이드 대상 노드: docker-desktop
    - 업그레이드 전 워크로드가 실행 중
    
    주의사항:
    - kubeadm upgrade plan으로 업그레이드 가능 여부 확인
    - 노드 drain 후 업그레이드 수행
    - kubelet, kubectl도 함께 업그레이드
EOF

# 4. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/061"
