#!/bin/bash
# Problem 034: HPA 스케일링 미동작 해결
# Domain: Troubleshooting
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q034"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. Deployment 생성 (resource requests 없음 - HPA 미동작 원인)
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "Deployment 생성 실패"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-deploy
  namespace: $NAMESPACE
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web-deploy
  template:
    metadata:
      labels:
        app: web-deploy
    spec:
      containers:
      - name: nginx
        image: nginx:1.24-alpine
        ports:
        - containerPort: 80
EOF

# 4. HPA 생성
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "HPA 생성 실패"
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: web-hpa
  namespace: $NAMESPACE
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: web-deploy
  minReplicas: 1
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
EOF

# 5. Deployment Ready 대기
kubectl -n "$NAMESPACE" wait --for=condition=Available deployment/web-deploy --timeout=60s || true

# 6. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/034"
echo -e "${YELLOW}[INFO] HPA 'web-hpa'가 CPU 사용률을 계산하지 못하고 있습니다.${NC}"
