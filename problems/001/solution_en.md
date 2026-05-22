# Problem 001: Solution

## Step 1: Create PersistentVolume

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: safari-pv
spec:
  capacity:
    storage: 2Gi
  accessModes:
    - ReadWriteOnce
  storageClassName: ""
  hostPath:
    path: /Volumes/Data
EOF
```

## Step 2: Create PersistentVolumeClaim

```bash
kubectl -n cka-q001 apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: safari-pvc
  namespace: cka-q001
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: ""
  resources:
    requests:
      storage: 2Gi
EOF
```

## Step 3: Verify PVC is Bound

```bash
kubectl -n cka-q001 get pvc safari-pvc
# Verify STATUS is Bound
```

## Step 4: Add Volume Mount to Deployment

```bash
kubectl -n cka-q001 patch deployment safari --type='json' -p='[
  {"op": "add", "path": "/spec/template/spec/volumes", "value": [{"name": "safari-data", "persistentVolumeClaim": {"claimName": "safari-pvc"}}]},
  {"op": "add", "path": "/spec/template/spec/containers/0/volumeMounts", "value": [{"name": "safari-data", "mountPath": "/tmp/safari-data"}]}
]'
```

Or edit directly with `kubectl -n cka-q001 edit deployment safari`:

```yaml
spec:
  template:
    spec:
      volumes:
      - name: safari-data
        persistentVolumeClaim:
          claimName: safari-pvc
      containers:
      - name: httpd
        # ... existing config ...
        volumeMounts:
        - name: safari-data
          mountPath: /tmp/safari-data
```

## Verification

```bash
kubectl get pv safari-pv
kubectl -n cka-q001 get pvc safari-pvc
kubectl -n cka-q001 describe pod -l app=safari | grep -A2 Mounts
```
