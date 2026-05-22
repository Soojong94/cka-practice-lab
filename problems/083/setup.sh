#!/bin/bash
# Problem 083: DNS FQDN 해석 (일반/Headless)
# Domain: Services & Networking
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q083"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. 일반 Service용 Deployment 및 Service 생성
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "리소스 생성 실패"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: normal-app
  labels:
    app: normal-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: normal-app
  template:
    metadata:
      labels:
        app: normal-app
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
  name: normal-svc
spec:
  type: ClusterIP
  selector:
    app: normal-app
  ports:
  - port: 80
    targetPort: 80
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: headless-app
  labels:
    app: headless-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: headless-app
  template:
    metadata:
      labels:
        app: headless-app
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
  name: headless-svc
spec:
  clusterIP: None
  selector:
    app: headless-app
  ports:
  - port: 80
    targetPort: 80
EOF

# 4. 리소스 Ready 대기
kubectl -n "$NAMESPACE" wait --for=condition=Available deployment/normal-app --timeout=60s || true
kubectl -n "$NAMESPACE" wait --for=condition=Available deployment/headless-app --timeout=60s || true

# 5. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/083"
