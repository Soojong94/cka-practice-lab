# Problem 004: Solution

## Step 1: Verify StorageClass

```bash
kubectl get storageclass expandable-sc -o yaml
# Confirm allowVolumeExpansion: true
```

## Step 2: Check current PVC capacity

```bash
kubectl -n cka-q004 get pvc data-pvc
# Verify CAPACITY is 1Gi
```

## Step 3: Expand PVC capacity (1Gi → 2Gi)

```bash
kubectl -n cka-q004 patch pvc data-pvc -p '{"spec":{"resources":{"requests":{"storage":"2Gi"}}}}'
```

Or edit directly with `kubectl -n cka-q004 edit pvc data-pvc`:

```yaml
spec:
  resources:
    requests:
      storage: 2Gi  # Change from 1Gi to 2Gi
```

## Step 4: Verify expansion result

```bash
# Check PVC spec
kubectl -n cka-q004 get pvc data-pvc -o jsonpath='{.spec.resources.requests.storage}'
# Output: 2Gi

# Check PVC actual capacity
kubectl -n cka-q004 get pvc data-pvc -o jsonpath='{.status.capacity.storage}'
# Output: 2Gi (may take time depending on CSI driver)

# Check Pod status
kubectl -n cka-q004 get pod volume-pod
# STATUS: Running
```

## Verification

```bash
kubectl -n cka-q004 get pvc data-pvc
kubectl -n cka-q004 get pod volume-pod
```
