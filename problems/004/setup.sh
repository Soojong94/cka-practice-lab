#!/bin/bash
# Problem 004: PV 용량 확장 (Volume Expansion)
# Domain: Storage
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q004"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. StorageClass 생성 (allowVolumeExpansion: true)
kubectl apply -f - <<EOF || fail_with_cleanup "$NAMESPACE" "StorageClass 생성 실패"
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: expandable-sc
provisioner: docker.io/hostpath
allowVolumeExpansion: true
reclaimPolicy: Delete
volumeBindingMode: Immediate
EOF

# 4. PVC 생성 (1Gi)
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "PVC 생성 실패"
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: expandable-sc
  resources:
    requests:
      storage: 1Gi
EOF

# 5. PVC를 사용하는 Pod 생성
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "Pod 생성 실패"
apiVersion: v1
kind: Pod
metadata:
  name: volume-pod
  labels:
    app: volume-pod
spec:
  containers:
  - name: busybox
    image: busybox:1.36
    command: ["sleep", "3600"]
    volumeMounts:
    - name: data-vol
      mountPath: /data
  volumes:
  - name: data-vol
    persistentVolumeClaim:
      claimName: data-pvc
EOF

# 6. 리소스 Ready 대기
kubectl -n "$NAMESPACE" wait --for=condition=Ready pod/volume-pod --timeout=60s || true

# 7. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/004"
