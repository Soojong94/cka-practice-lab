# Problem 003: Solution

## Step 1: Check current reclaimPolicy

```bash
kubectl get pv cka-q003-data-pv -o jsonpath='{.spec.persistentVolumeReclaimPolicy}'
# Output: Delete
```

## Step 2: Change reclaimPolicy to Retain

```bash
kubectl patch pv cka-q003-data-pv -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'
```

## Step 3: Delete Pod

```bash
kubectl -n cka-q003 delete pod data-writer
```

## Step 4: Delete PVC

```bash
kubectl -n cka-q003 delete pvc data-pvc
```

## Step 5: Verify PV status

```bash
kubectl get pv cka-q003-data-pv
# STATUS should be Released (PV is preserved due to Retain policy)
```
