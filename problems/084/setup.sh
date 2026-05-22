#!/bin/bash
# Problem 084: Headless Service 구성
# Domain: Services & Networking
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q084"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. StatefulSet "db" 생성 (3 replicas) - Headless Service 없이
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "리소스 생성 실패"
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: db
spec:
  serviceName: "db-headless"
  replicas: 3
  selector:
    matchLabels:
      app: db
  template:
    metadata:
      labels:
        app: db
    spec:
      containers:
      - name: busybox
        image: busybox:1.36
        command: ["sh", "-c", "while true; do echo running; sleep 3600; done"]
        ports:
        - containerPort: 5432
EOF

# 4. 리소스 Ready 대기 (StatefulSet은 순차적으로 생성됨)
echo -e "${YELLOW}[INFO] StatefulSet Pod 생성 대기 중...${NC}"
kubectl -n "$NAMESPACE" wait --for=condition=Ready pod/db-0 --timeout=60s || true
kubectl -n "$NAMESPACE" wait --for=condition=Ready pod/db-1 --timeout=60s || true
kubectl -n "$NAMESPACE" wait --for=condition=Ready pod/db-2 --timeout=60s || true

# 5. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/084"
