# Problem 010: Solution

## Step 1: Analyze current state

```bash
# Check PV spec
kubectl get pv debug-pv -o yaml
# storageClassName: manual
# accessModes: [ReadWriteOnce]
# capacity: 2Gi

# Check PVC spec
kubectl -n cka-q010 get pvc debug-pvc -o yaml
# storageClassName: wrong-class  ← Issue 1: Mismatch with PV
# accessModes: [ReadWriteMany]   ← Issue 2: Mismatch with PV

# Check PVC status
kubectl -n cka-q010 get pvc debug-pvc
# STATUS: Pending
```

## Step 2: Identify root cause

1. **storageClassName mismatch**: PV is `manual`, PVC is `wrong-class`
2. **accessModes mismatch**: PV is `ReadWriteOnce`, PVC is `ReadWriteMany`

## Step 3: Delete PVC and recreate with correct spec

PVC `storageClassName` and `accessModes` are immutable fields, so the PVC must be deleted and recreated.

```bash
# Delete existing PVC
kubectl -n cka-q010 delete pvc debug-pvc

# Recreate PVC with correct spec
kubectl -n cka-q010 apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: debug-pvc
  namespace: cka-q010
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: manual
  resources:
    requests:
      storage: 2Gi
EOF
```

## Step 4: Verify binding

```bash
kubectl -n cka-q010 get pvc debug-pvc
# NAME        STATUS   VOLUME     CAPACITY   ACCESS MODES   STORAGECLASS
# debug-pvc   Bound    debug-pv   2Gi        RWO            manual

kubectl get pv debug-pv
# NAME       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM
# debug-pv   2Gi        RWO            Retain           Bound    cka-q010/debug-pvc
```

## Verification

```bash
kubectl -n cka-q010 get pvc debug-pvc -o jsonpath='{.status.phase}'
# Output: Bound
```
