#!/bin/bash
# Problem 050: Pod Priority와 Preemption
# Domain: Workloads & Scheduling
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q050"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. PriorityClass 생성
kubectl apply -f - <<EOF || fail_with_cleanup "$NAMESPACE" "PriorityClass 생성 실패"
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: high-priority
value: 1000000
globalDefault: false
description: "High priority class for important workloads"
EOF

echo -e "${GREEN}[OK] PriorityClass 'high-priority' (value=1000000) 생성됨${NC}"

# 4. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/050"
