#!/bin/bash
# Problem 003: PV Reclaim Policy 변경 및 검증
# Domain: Storage
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q003"

check_cluster
init_namespace "$NAMESPACE"

# PV 생성 (reclaimPolicy: Delete)
kubectl apply -f - <<EOF || fail_with_cleanup "$NAMESPACE" "PV 생성 실패"
apiVersion: v1
kind: PersistentVolume
metadata:
  name: cka-q003-data-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Delete
  storageClassName: ""
  hostPath:
    path: /tmp/cka-q003-data
EOF

# PVC 생성 및 바인딩
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "PVC 생성 실패"
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: ""
  resources:
    requests:
      storage: 1Gi
EOF

# PVC를 사용하는 Pod 생성
kubectl apply -n "$NAMESPACE" -f - <<EOF || fail_with_cleanup "$NAMESPACE" "Pod 생성 실패"
apiVersion: v1
kind: Pod
metadata:
  name: data-writer
spec:
  containers:
  - name: writer
    image: busybox:1.36
    command: ["sh", "-c", "echo 'important data' > /data/file.txt && sleep 3600"]
    volumeMounts:
    - name: data
      mountPath: /data
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: data-pvc
EOF

kubectl -n "$NAMESPACE" wait --for=condition=Ready pod/data-writer --timeout=60s || true

print_setup_complete "$NAMESPACE" "problems/003"
