#!/bin/bash
# Problem 047: HPA 구성 (CPU 기반 오토스케일링)
# Domain: Workloads & Scheduling
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q047"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. metrics-server 확인 (Docker Desktop에는 보통 설치되어 있음)
if ! kubectl get deployment metrics-server -n kube-system &>/dev/null; then
  echo -e "${YELLOW}[INFO] metrics-server가 설치되어 있지 않습니다. 설치 중...${NC}"
  kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml 2>/dev/null || true
  # Docker Desktop에서는 --kubelet-insecure-tls 필요할 수 있음
  kubectl -n kube-system patch deployment metrics-server --type='json' -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"}]' 2>/dev/null || true
fi

# 4. Deployment 생성 (리소스 요청 포함)
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "리소스 생성 실패"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hpa-target
  namespace: $NAMESPACE
spec:
  replicas: 1
  selector:
    matchLabels:
      app: hpa-target
  template:
    metadata:
      labels:
        app: hpa-target
    spec:
      containers:
      - name: nginx
        image: nginx:1-alpine
        resources:
          requests:
            cpu: "100m"
        ports:
        - containerPort: 80
EOF

# 5. 리소스 Ready 대기
kubectl -n "$NAMESPACE" wait --for=condition=Available deployment/hpa-target --timeout=60s || true

# 6. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/047"
