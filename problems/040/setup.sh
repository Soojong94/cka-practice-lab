#!/bin/bash
# Problem 040: Cluster Event 분석 및 로깅
# Domain: Troubleshooting
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q040"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. 성공적인 Deployment 생성
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

# 4. 실패하는 Pod 생성 (잘못된 이미지)
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "Pod 생성 실패"
apiVersion: v1
kind: Pod
metadata:
  name: failing-pod
  namespace: $NAMESPACE
  labels:
    app: failing-pod
spec:
  containers:
  - name: app
    image: nginx:nonexistent-tag-12345
    ports:
    - containerPort: 80
EOF

# 5. Deployment 스케일링 (이벤트 생성)
kubectl -n "$NAMESPACE" wait --for=condition=Available deployment/web-app --timeout=60s || true
kubectl -n "$NAMESPACE" scale deployment web-app --replicas=3

# 6. 잠시 대기 (이벤트 생성)
sleep 10

# 7. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/040"
echo -e "${YELLOW}[INFO] 다양한 이벤트가 생성되었습니다. 이벤트를 분석하고 스크립트를 작성하세요.${NC}"
