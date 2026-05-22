#!/bin/bash
# Problem 092: Ingress TLS 설정
# Domain: Services & Networking
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q092"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. Deployment + Service 생성
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "리소스 생성 실패"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: secure-app
  labels:
    app: secure-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: secure-app
  template:
    metadata:
      labels:
        app: secure-app
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
  name: secure-app-svc
spec:
  selector:
    app: secure-app
  ports:
  - port: 80
    targetPort: 80
EOF

# 4. 자체 서명 TLS 인증서 생성
echo -e "${YELLOW}[INFO] 자체 서명 TLS 인증서 생성 중...${NC}"
kubectl -n "$NAMESPACE" run cert-gen --image=alpine --restart=Never \
  --command -- sleep 3600 2>/dev/null || true
kubectl -n "$NAMESPACE" wait --for=condition=Ready pod/cert-gen --timeout=30s 2>/dev/null || true

# openssl로 인증서 생성 (로컬에서)
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /tmp/tls-092.key -out /tmp/tls-092.crt \
  -subj "/CN=secure.example.com/O=CKA-Lab" 2>/dev/null

# 인증서 파일을 ConfigMap으로 저장 (사용자가 Secret 생성에 활용)
kubectl -n "$NAMESPACE" create configmap tls-files \
  --from-file=tls.crt=/tmp/tls-092.crt \
  --from-file=tls.key=/tmp/tls-092.key 2>/dev/null || true

# 임시 파일 정리
rm -f /tmp/tls-092.key /tmp/tls-092.crt
kubectl -n "$NAMESPACE" delete pod cert-gen --grace-period=0 --force 2>/dev/null || true

# 5. 리소스 Ready 대기
kubectl -n "$NAMESPACE" wait --for=condition=Available deployment/secure-app --timeout=60s || true

# 6. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/092"
