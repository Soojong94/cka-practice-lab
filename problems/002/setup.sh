#!/bin/bash
# Problem 002: StorageClass 동적 프로비저닝
# Domain: Storage
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q002"

check_cluster
init_namespace "$NAMESPACE"

# rancher local-path provisioner 설치 (동적 프로비저닝 지원)
# kind 등 이미 local-path provisioner가 있는 클러스터는 그대로 사용
if kubectl get storageclass -o jsonpath='{.items[*].provisioner}' 2>/dev/null | grep -q "rancher.io/local-path"; then
  echo -e "${YELLOW}[INFO] local-path provisioner가 이미 있어 설치를 건너뜁니다${NC}"
else
  kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.26/deploy/local-path-storage.yaml >/dev/null 2>&1 || true
fi

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
