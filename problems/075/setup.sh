#!/bin/bash
# Problem 075: Container Runtime 정보 확인 (CRI)
# Domain: Cluster Architecture, Installation & Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q075"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. 답안 작성용 ConfigMap 생성
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "리소스 생성 실패"
apiVersion: v1
kind: ConfigMap
metadata:
  name: cri-info
  namespace: $NAMESPACE
data:
  runtime-version: "# TODO: 노드의 컨테이너 런타임 버전을 기록하세요 (예: containerd://1.x.x)"
  runtime-endpoint: "# TODO: containerd 소켓 경로를 기록하세요"
  list-containers-command: "# TODO: 실행 중인 컨테이너를 조회하는 crictl 명령어"
  inspect-command: "# TODO: 특정 컨테이너를 상세 조회하는 crictl 명령어 형식"
EOF

# 4. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/075"
