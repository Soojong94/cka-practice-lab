#!/bin/bash
# Problem 030: scheduler 중지 후 수동 스케줄링
# Domain: Troubleshooting
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q030"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. 현재 노드 이름 가져오기
NODE_NAME=$(lab_node)

# 4. Pending 상태의 Pod 생성 (존재하지 않는 nodeSelector로 스케줄링 불가)
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "리소스 생성 실패"
apiVersion: v1
kind: Pod
metadata:
  name: manual-schedule-pod
  labels:
    app: manual-schedule
spec:
  containers:
  - name: nginx
    image: nginx:alpine
  nodeSelector:
    kubernetes.io/hostname: nonexistent-node-xyz
EOF

# 5. 잠시 대기하여 Pending 상태 확인
sleep 3

# 6. 노드 이름을 ConfigMap으로 제공 (힌트용)
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "리소스 생성 실패"
apiVersion: v1
kind: ConfigMap
metadata:
  name: cluster-info
data:
  node-name: "$NODE_NAME"
  hint: "이 노드에 Pod를 수동으로 스케줄링하세요"
EOF

# 7. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/030"
