#!/bin/bash
# Problem 064: CRD 생성 및 Custom Resource 관리
# Domain: Cluster Architecture, Installation & Configuration
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q064"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. 기존 CRD 정리 (이전 실행 잔여물)
kubectl delete crd databases.stable.example.com --ignore-not-found 2>/dev/null || true

# 4. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/064"
