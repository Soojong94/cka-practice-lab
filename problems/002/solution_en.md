# Problem 002: Solution

## Step 1: Create StorageClass

```bash
kubectl apply -f - <<EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-backup
provisioner: rancher.io/local-path
reclaimPolicy: Retain
volumeBindingMode: WaitForFirstConsumer
EOF
```

## Step 2: Create PVC

```bash
kubectl -n cka-q002 apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: backup-pvc
  namespace: cka-q002
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: local-backup
  resources:
    requests:
      storage: 50Mi
EOF
```

## Step 3: Delete existing Job and create new Job

```bash
kubectl -n cka-q002 delete job backup-job

kubectl -n cka-q002 apply -f - <<EOF
apiVersion: batch/v1
kind: Job
metadata:
  name: backup-job
  namespace: cka-q002
spec:
  backoffLimit: 0
  template:
    spec:
      volumes:
      - name: backup-vol
        persistentVolumeClaim:
          claimName: backup-pvc
      containers:
      - name: backup
        image: busybox:1.36
        command: ["sh", "-c", "echo backup-\$(date +%Y%m%d) > /backup/latest.txt && cat /backup/latest.txt"]
        volumeMounts:
        - name: backup-vol
          mountPath: /backup
      restartPolicy: Never
EOF
```

## Verification

```bash
kubectl get sc local-backup
kubectl -n cka-q002 get pvc backup-pvc
kubectl -n cka-q002 get job backup-job
kubectl -n cka-q002 logs job/backup-job
```
