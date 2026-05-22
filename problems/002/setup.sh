#!/bin/bash
# Problem 002: StorageClass 동적 프로비저닝
# Domain: Storage
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q002"

check_cluster
init_namespace "$NAMESPACE"

# rancher local-path provisioner 설치 (동적 프로비저닝 지원)
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.26/deploy/local-path-storage.yaml 2>/dev/null || true

# 기존 StorageClass 확인용 Job 생성
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "리소스 생성 실패"
apiVersion: batch/v1
kind: Job
metadata:
  name: backup-job
spec:
  backoffLimit: 0
  template:
    spec:
      containers:
      - name: backup
        image: busybox:1.36
        command: ["sh", "-c", "echo 'waiting for storage...' && sleep 3600"]
      restartPolicy: Never
EOF

print_setup_complete "$NAMESPACE" "problems/002"
