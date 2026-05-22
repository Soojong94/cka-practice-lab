#!/bin/bash
# Problem 054: StatefulSet 스케일링 및 관리
# Domain: Workloads & Scheduling
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q054"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. Headless Service 생성
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "Service 생성 실패"
apiVersion: v1
kind: Service
metadata:
  name: web-headless
  namespace: $NAMESPACE
spec:
  clusterIP: None
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 80
EOF

# 4. StatefulSet 생성 (3 replicas)
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "StatefulSet 생성 실패"
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
  namespace: $NAMESPACE
spec:
  serviceName: web-headless
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: nginx
        image: nginx:1-alpine
        ports:
        - containerPort: 80
EOF

# 5. StatefulSet Ready 대기
echo -e "${YELLOW}[INFO] StatefulSet Pod 생성 대기 중...${NC}"
kubectl -n "$NAMESPACE" rollout status statefulset/web --timeout=90s || true

# 6. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/054"
