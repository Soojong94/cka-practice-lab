#!/bin/bash
# Problem 038: Node 레이블/taint 불일치 해결
# Domain: Troubleshooting
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q038"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. 노드 이름 가져오기
# 일반 Pod가 뜰 수 있는 모든 노드에 taint (어느 노드에 레이블을 붙여도 toleration 필요)

# 4. 노드에 taint 추가
for NODE_NAME in $(lab_nodes); do
  kubectl taint nodes "$NODE_NAME" dedicated=special:NoSchedule --overwrite >/dev/null 2>&1 || true
done

echo -e "${YELLOW}[INFO] 노드 $(lab_nodes | tr '\n' ' ')에 taint 'dedicated=special:NoSchedule' 추가됨${NC}"

# 5. nodeSelector가 있지만 레이블이 없는 Pod 생성 (Pending 상태)
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "Pod 생성 실패"
apiVersion: v1
kind: Pod
metadata:
  name: ssd-pod
  namespace: $NAMESPACE
  labels:
    app: ssd-pod
spec:
  nodeSelector:
    disk: ssd
  containers:
  - name: nginx
    image: nginx:1.24-alpine
    ports:
    - containerPort: 80
EOF

# 6. 잠시 대기
sleep 5

# 7. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/038"
echo -e "${YELLOW}[INFO] Pod 'ssd-pod'가 Pending 상태입니다. nodeSelector와 taint 문제를 해결하세요.${NC}"
