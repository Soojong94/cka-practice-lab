#!/bin/bash
# Problem 089: Gateway API - HTTPRoute 경로 라우팅
# Domain: Services & Networking
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q089"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. Gateway API CRDs 설치 (없는 경우)
if ! kubectl get crd gateways.gateway.networking.k8s.io &>/dev/null; then
  kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml 2>/dev/null || true
fi

# 4. GatewayClass 및 Gateway 생성
kubectl apply -f - <<EOF || true
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: example-gc-089
spec:
  controllerName: example.com/gateway-controller
EOF

kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "리소스 생성 실패"
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: api-gateway
spec:
  gatewayClassName: example-gc-089
  listeners:
  - name: http
    protocol: HTTP
    port: 80
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: svc-v1
  labels:
    app: svc-v1
spec:
  replicas: 1
  selector:
    matchLabels:
      app: svc-v1
  template:
    metadata:
      labels:
        app: svc-v1
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: svc-v1
spec:
  selector:
    app: svc-v1
  ports:
  - port: 80
    targetPort: 80
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: svc-v2
  labels:
    app: svc-v2
spec:
  replicas: 1
  selector:
    matchLabels:
      app: svc-v2
  template:
    metadata:
      labels:
        app: svc-v2
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: svc-v2
spec:
  selector:
    app: svc-v2
  ports:
  - port: 80
    targetPort: 80
EOF

# 5. 리소스 Ready 대기
kubectl -n "$NAMESPACE" wait --for=condition=Available deployment/svc-v1 --timeout=60s || true
kubectl -n "$NAMESPACE" wait --for=condition=Available deployment/svc-v2 --timeout=60s || true

# 6. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/089"
