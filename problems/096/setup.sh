#!/bin/bash
# Problem 096: Pod 간 통신 테스트 및 디버깅
# Domain: Services & Networking
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q096"
NS_A="cka-q096-a"
NS_B="cka-q096-b"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NS_A"
init_namespace "$NS_B"

# 3. NS_A에 pod-a 생성
kubectl apply -n "$NS_A" -f - <<EOF || fail_with_cleanup "$NS_A" "리소스 생성 실패"
apiVersion: v1
kind: Pod
metadata:
  name: pod-a
  labels:
    app: pod-a
spec:
  containers:
  - name: curl
    image: curlimages/curl:latest
    command: ["sleep", "3600"]
EOF

# 4. NS_B에 pod-b + Service 생성
kubectl apply -n "$NS_B" -f - <<EOF || fail_with_cleanup "$NS_B" "리소스 생성 실패"
apiVersion: v1
kind: Pod
metadata:
  name: pod-b
  labels:
    app: pod-b
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
  name: svc-b
spec:
  selector:
    app: pod-b
  ports:
  - port: 80
    targetPort: 80
EOF

# 5. 리소스 Ready 대기
kubectl -n "$NS_A" wait --for=condition=Ready pod/pod-a --timeout=60s || true
kubectl -n "$NS_B" wait --for=condition=Ready pod/pod-b --timeout=60s || true

# 6. 완료 메시지
echo ""
echo -e "${BLUE}=========================================${NC}"
echo -e "${GREEN} 환경 세팅 완료!${NC}"
echo -e "${BLUE}=========================================${NC}"
echo -e " 네임스페이스: ${YELLOW}$NS_A, $NS_B${NC}"
echo " 생성된 리소스:"
echo "  [$NS_A]"
kubectl -n "$NS_A" get all 2>/dev/null
echo "  [$NS_B]"
kubectl -n "$NS_B" get all 2>/dev/null
echo ""
echo -e " 문제를 확인하세요: ${YELLOW}problems/096/problem.md${NC}"
echo -e "${BLUE}=========================================${NC}"
