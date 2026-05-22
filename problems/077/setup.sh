#!/bin/bash
# Problem 077: CSI 드라이버 확인
# Domain: Cluster Architecture, Installation & Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q077"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. 답안 작성용 ConfigMap 생성
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "리소스 생성 실패"
apiVersion: v1
kind: ConfigMap
metadata:
  name: csi-info
  namespace: $NAMESPACE
data:
  csi-drivers: "# TODO: 클러스터에 등록된 CSI 드라이버 목록을 기록하세요"
  storage-classes: "# TODO: StorageClass와 provisioner 매핑을 기록하세요 (형식: SC이름: provisioner)"
  default-storage-class: "# TODO: 기본 StorageClass 이름을 기록하세요"
EOF

# 4. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/077"
