#!/bin/bash
# Problem 020: NetworkPolicy로 인한 통신 차단 해결
# Domain: Troubleshooting
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q020"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. Server Pod 생성 (nginx, 라벨: role=server)
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "리소스 생성 실패"
apiVersion: v1
kind: Pod
metadata:
  name: server
  labels:
    role: server
spec:
  containers:
  - name: nginx
    image: nginx:1.25-alpine
    ports:
    - containerPort: 80
EOF

# 4. Client Pod 생성 (curl 가능한 이미지, 라벨: role=client)
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "리소스 생성 실패"
apiVersion: v1
kind: Pod
metadata:
  name: client
  labels:
    role: client
spec:
  containers:
  - name: curl
    image: curlimages/curl:8.4.0
    command: ["sleep", "3600"]
EOF

# 5. 모든 인바운드 트래픽을 차단하는 NetworkPolicy 생성
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "NetworkPolicy 생성 실패"
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-ingress
spec:
  podSelector:
    matchLabels:
      role: server
  policyTypes:
  - Ingress
EOF

# 6. Pod Ready 대기
echo -e "${YELLOW}[INFO] Pod 준비 대기 중...${NC}"
kubectl -n "$NAMESPACE" wait --for=condition=Ready pod/server --timeout=60s || true
kubectl -n "$NAMESPACE" wait --for=condition=Ready pod/client --timeout=60s || true

# 7. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/020"
