#!/bin/bash
# Problem 035: Job/CronJob 실패 분석
# Domain: Troubleshooting
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q035"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. 실패하는 Job 생성 (exit 1 명령)
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "Job 생성 실패"
apiVersion: batch/v1
kind: Job
metadata:
  name: data-process
  namespace: $NAMESPACE
spec:
  backoffLimit: 3
  template:
    spec:
      containers:
      - name: processor
        image: busybox:1.36
        command: ["/bin/sh", "-c", "echo 'Processing data...' && exit 1"]
      restartPolicy: Never
EOF

# 4. Job 실패 대기
echo -e "${YELLOW}[INFO] Job이 실패할 때까지 대기 중...${NC}"
sleep 15

# 5. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/035"
echo -e "${YELLOW}[INFO] Job 'data-process'가 실패 상태입니다.${NC}"
