#!/bin/bash
# Problem 100: NetworkPolicy + Service 통합 시나리오
# Domain: Services & Networking
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NS_FRONTEND="cka-q100-frontend"
NS_BACKEND="cka-q100-backend"
NS_DB="cka-q100-db"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NS_FRONTEND"
init_namespace "$NS_BACKEND"
init_namespace "$NS_DB"

# 3. Frontend 네임스페이스 리소스
kubectl apply -n "$NS_FRONTEND" -f - <<EOF || fail_with_cleanup "$NS_FRONTEND" "리소스 생성 실패"
apiVersion: v1
kind: Pod
metadata:
  name: frontend
  labels:
    role: frontend
spec:
  containers:
  - name: curl
    image: curlimages/curl:latest
    command: ["sleep", "3600"]
---
apiVersion: v1
kind: Service
metadata:
  name: frontend-svc
spec:
  selector:
    role: frontend
  ports:
  - port: 80
    targetPort: 80
EOF

# 4. Backend 네임스페이스 리소스
kubectl apply -n "$NS_BACKEND" -f - <<EOF || fail_with_cleanup "$NS_BACKEND" "리소스 생성 실패"
apiVersion: v1
kind: Pod
metadata:
  name: backend
  labels:
    role: backend
spec:
  containers:
  - name: nginx
    image: nginx:alpine
    ports:
    - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: backend-svc
spec:
  selector:
    role: backend
  ports:
  - port: 8080
    targetPort: 8080
EOF

# 5. DB 네임스페이스 리소스
kubectl apply -n "$NS_DB" -f - <<EOF || fail_with_cleanup "$NS_DB" "리소스 생성 실패"
apiVersion: v1
kind: Pod
metadata:
  name: db
  labels:
    role: db
spec:
  containers:
  - name: postgres
    image: busybox:1.36
    command: ["sh", "-c", "while true; do nc -l -p 5432 -e echo connected; done"]
    ports:
    - containerPort: 5432
---
apiVersion: v1
kind: Service
metadata:
  name: db-svc
spec:
  selector:
    role: db
  ports:
  - port: 5432
    targetPort: 5432
EOF

# 6. 리소스 Ready 대기
kubectl -n "$NS_FRONTEND" wait --for=condition=Ready pod/frontend --timeout=60s || true
kubectl -n "$NS_BACKEND" wait --for=condition=Ready pod/backend --timeout=60s || true
kubectl -n "$NS_DB" wait --for=condition=Ready pod/db --timeout=60s || true

# 7. 완료 메시지
echo ""
echo -e "${BLUE}=========================================${NC}"
echo -e "${GREEN} 환경 세팅 완료!${NC}"
echo -e "${BLUE}=========================================${NC}"
echo -e " 네임스페이스: ${YELLOW}$NS_FRONTEND, $NS_BACKEND, $NS_DB${NC}"
echo " 생성된 리소스:"
echo "  [$NS_FRONTEND]"
kubectl -n "$NS_FRONTEND" get all 2>/dev/null
echo "  [$NS_BACKEND]"
kubectl -n "$NS_BACKEND" get all 2>/dev/null
echo "  [$NS_DB]"
kubectl -n "$NS_DB" get all 2>/dev/null
echo ""
echo -e " 문제를 확인하세요: ${YELLOW}problems/100/problem.md${NC}"
echo -e "${BLUE}=========================================${NC}"
