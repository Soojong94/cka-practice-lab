#!/bin/bash
# Problem 033: Ingress 라우팅 오류 수정
# Domain: Troubleshooting
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q033"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. Deployment 생성
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "Deployment 생성 실패"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  namespace: $NAMESPACE
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: nginx
        image: nginx:1.24-alpine
        ports:
        - containerPort: 80
EOF

# 4. Service 생성 (port 80)
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "Service 생성 실패"
apiVersion: v1
kind: Service
metadata:
  name: web-svc
  namespace: $NAMESPACE
spec:
  selector:
    app: web-app
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
EOF

# 5. 잘못된 Ingress 생성 (pathType: Exact, 잘못된 service port 8080)
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "Ingress 생성 실패"
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-ingress
  namespace: $NAMESPACE
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: web-app.example.com
    http:
      paths:
      - path: /app
        pathType: Exact
        backend:
          service:
            name: web-svc
            port:
              number: 8080
EOF

# 6. Deployment Ready 대기
kubectl -n "$NAMESPACE" wait --for=condition=Available deployment/web-app --timeout=60s || true

# 7. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/033"
echo -e "${YELLOW}[INFO] Ingress 'web-ingress'에 라우팅 오류가 있습니다.${NC}"
