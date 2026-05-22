#!/bin/bash
# Problem 037: 컨트롤플레인 컴포넌트 확인 및 문서화
# Domain: Troubleshooting
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q037"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. 빈 ConfigMap 템플릿 생성 (학생이 채워야 함)
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "ConfigMap 생성 실패"
apiVersion: v1
kind: ConfigMap
metadata:
  name: cluster-info
  namespace: $NAMESPACE
data:
  kube-apiserver-type: ""
  kube-apiserver-node: ""
  kube-apiserver-image: ""
  etcd-type: ""
  etcd-node: ""
  etcd-image: ""
  kube-scheduler-type: ""
  kube-scheduler-node: ""
  kube-scheduler-image: ""
  kube-controller-manager-type: ""
  kube-controller-manager-node: ""
  kube-controller-manager-image: ""
  coredns-type: ""
  coredns-node: ""
  coredns-image: ""
EOF

# 4. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/037"
echo -e "${YELLOW}[INFO] ConfigMap 'cluster-info'의 빈 필드를 채워야 합니다.${NC}"
