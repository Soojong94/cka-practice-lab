# Problem 005: Solution

## Step 1: Create PersistentVolume

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: shared-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteMany
  storageClassName: manual
  hostPath:
    path: /tmp/shared-data
EOF
```

## Step 2: Create PersistentVolumeClaim

```bash
kubectl -n cka-q005 apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: shared-pvc
  namespace: cka-q005
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: manual
  resources:
    requests:
      storage: 1Gi
EOF
```

## Step 3: Verify PVC is Bound

```bash
kubectl -n cka-q005 get pvc shared-pvc
# Verify STATUS is Bound
```

## Step 4: Create writer-pod

```bash
kubectl -n cka-q005 apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: writer-pod
spec:
  containers:
  - name: writer
    image: busybox:1.36
    command: ["sh", "-c", "echo 'hello from writer' > /shared/data.txt && sleep 3600"]
    volumeMounts:
    - name: shared-vol
      mountPath: /shared
  volumes:
  - name: shared-vol
    persistentVolumeClaim:
      claimName: shared-pvc
EOF
```

## Step 5: Create reader-pod

```bash
kubectl -n cka-q005 apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: reader-pod
spec:
  containers:
  - name: reader
    image: busybox:1.36
    command: ["sh", "-c", "cat /shared/data.txt && sleep 3600"]
    volumeMounts:
    - name: shared-vol
      mountPath: /shared
  volumes:
  - name: shared-vol
    persistentVolumeClaim:
      claimName: shared-pvc
EOF
```

## Verification

```bash
kubectl -n cka-q005 get pvc shared-pvc
kubectl -n cka-q005 get pods
kubectl -n cka-q005 exec reader-pod -- cat /shared/data.txt
```
