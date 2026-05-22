#!/bin/bash
# Problem 026: 컨테이너 런타임 문제 해결
# Domain: Troubleshooting
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q026"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. Pod 1: 유효한 이미지이지만 잘못된 command로 즉시 종료되는 Pod
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "리소스 생성 실패"
apiVersion: v1
kind: Pod
metadata:
  name: app-crash
  labels:
    app: app-crash
spec:
  containers:
  - name: nginx
    image: nginx:alpine
    command: ["/bin/sh", "-c", "exit 1"]
EOF

# 4. Pod 2: 존재하지 않는 이미지를 사용하는 Pod (ImagePullBackOff)
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "리소스 생성 실패"
apiVersion: v1
kind: Pod
metadata:
  name: app-imagepull
  labels:
    app: app-imagepull
spec:
  containers:
  - name: app
    image: nginx:nonexistent-tag-v999
    command: ["/bin/sh", "-c", "sleep 3600"]
EOF

# 5. 잠시 대기하여 에러 상태 발생
sleep 5

# 6. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/026"
