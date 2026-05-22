#!/bin/bash
# Problem 090: Gateway API - 헤더 기반 라우팅
# Domain: Services & Networking
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q090"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. Gateway API CRDs 설치 (없는 경우)
if ! kubectl get crd gateways.gateway.networking.k8s.io &>/dev/null; then
  kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml 2>/dev/null || true
fi

# 4. GatewayClass 및 Gateway, Services 생성
kubectl apply -f - <<EOF || true
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: example-gc-090
spec:
  controllerName: example.com/gateway-controller
EOF

kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "리소스 생성 실패"
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: header-gateway
spec:
  gatewayClassName: example-gc-090
  listeners:
  - name: http
    protocol: HTTP
    port: 80
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mobile-app
  labels:
    app: mobile-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mobile-app
  template:
    metadata:
      labels:
        app: mobile-app
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
  name: mobile-svc
spec:
  selector:
    app: mobile-app
  ports:
  - port: 80
    targetPort: 80
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: desktop-app
  labels:
    app: desktop-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: desktop-app
  template:
    metadata:
      labels:
        app: desktop-app
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
  name: desktop-svc
spec:
  selector:
    app: desktop-app
  ports:
  - port: 80
    targetPort: 80
EOF

# 5. 리소스 Ready 대기
kubectl -n "$NAMESPACE" wait --for=condition=Available deployment/mobile-app --timeout=60s || true
kubectl -n "$NAMESPACE" wait --for=condition=Available deployment/desktop-app --timeout=60s || true

# 6. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/090"
