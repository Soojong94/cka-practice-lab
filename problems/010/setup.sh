#!/bin/bash
# Problem 010: PVC Binding 트러블슈팅
# Domain: Storage / Troubleshooting
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q010"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. PV 생성 (storageClassName: manual, accessModes: ReadWriteOnce)
kubectl apply -f - <<EOF || fail_with_cleanup "$NAMESPACE" "PV 생성 실패"
apiVersion: v1
kind: PersistentVolume
metadata:
  name: debug-pv
spec:
  capacity:
    storage: 2Gi
  accessModes:
    - ReadWriteOnce
  storageClassName: manual
  hostPath:
    path: /tmp/debug-data
  persistentVolumeReclaimPolicy: Retain
EOF

# 4. PVC 생성 (의도적으로 잘못된 설정: storageClassName 불일치, accessModes 불일치)
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "PVC 생성 실패"
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: debug-pvc
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: wrong-class
  resources:
    requests:
      storage: 2Gi
EOF

# 5. 상태 확인 메시지
echo -e "${YELLOW}[INFO] PVC 'debug-pvc'가 Pending 상태입니다 (의도적 오류).${NC}"
echo -e "${YELLOW}[INFO] PV와 PVC의 설정을 비교하여 문제를 해결하세요.${NC}"

# 6. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/010"
