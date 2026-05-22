#!/bin/bash
# Problem 069: API 리소스 탐색
# Domain: Cluster Architecture, Installation & Configuration
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q069"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. 답안 템플릿 ConfigMap 생성
kubectl -n "$NAMESPACE" apply -f - <<EOF || fail_with_cleanup "$NAMESPACE" "리소스 생성 실패"
apiVersion: v1
kind: ConfigMap
metadata:
  name: api-info-template
  namespace: ${NAMESPACE}
data:
  instructions: |
    다음 정보를 조사하여 ConfigMap 'api-info'에 저장하세요:
    1. namespaced-count: namespaced 리소스 타입 수
    2. deployments-apigroup: deployments의 API 그룹
    3. cronjobs-namespaced: cronjobs가 namespaced인지 (true/false)
    4. nodes-namespaced: nodes가 namespaced인지 (true/false)
    
    사용할 명령: kubectl api-resources
EOF

# 4. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/069"
