#!/bin/bash
# Problem 021: Pod QoS 클래스 분석 및 종료 순서
# Domain: Troubleshooting
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q021"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. Guaranteed QoS Pod (requests == limits)
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "리소스 생성 실패"
apiVersion: v1
kind: Pod
metadata:
  name: pod-guaranteed
  labels:
    tier: guaranteed
spec:
  containers:
  - name: nginx
    image: nginx:alpine
    resources:
      requests:
        memory: "64Mi"
        cpu: "100m"
      limits:
        memory: "64Mi"
        cpu: "100m"
EOF

# 4. Burstable QoS Pod (requests < limits)
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "리소스 생성 실패"
apiVersion: v1
kind: Pod
metadata:
  name: pod-burstable
  labels:
    tier: burstable
spec:
  containers:
  - name: nginx
    image: nginx:alpine
    resources:
      requests:
        memory: "32Mi"
        cpu: "50m"
      limits:
        memory: "128Mi"
        cpu: "200m"
EOF

# 5. BestEffort QoS Pod (no requests/limits)
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "리소스 생성 실패"
apiVersion: v1
kind: Pod
metadata:
  name: pod-besteffort
  labels:
    tier: besteffort
spec:
  containers:
  - name: nginx
    image: nginx:alpine
EOF

# 6. 리소스 Ready 대기
kubectl -n "$NAMESPACE" wait --for=condition=Ready pod/pod-guaranteed --timeout=60s || true
kubectl -n "$NAMESPACE" wait --for=condition=Ready pod/pod-burstable --timeout=60s || true
kubectl -n "$NAMESPACE" wait --for=condition=Ready pod/pod-besteffort --timeout=60s || true

# 7. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/021"
