#!/bin/bash
# Problem 095: CoreDNS 커스텀 도메인 추가
# Domain: Services & Networking
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q095"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. CoreDNS ConfigMap 백업
echo -e "${YELLOW}[INFO] CoreDNS ConfigMap 백업 중...${NC}"
coredns_backup || fail_with_cleanup "$NAMESPACE" "CoreDNS 백업 실패"

# 4. 테스트용 Service 생성
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "리소스 생성 실패"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-app
  labels:
    app: test-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: test-app
  template:
    metadata:
      labels:
        app: test-app
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
  name: test-svc
spec:
  selector:
    app: test-app
  ports:
  - port: 80
    targetPort: 80
EOF

# 5. 리소스 Ready 대기
kubectl -n "$NAMESPACE" wait --for=condition=Available deployment/test-app --timeout=60s || true

# 6. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/095"
