# Problem 002: StorageClass Dynamic Provisioning

| Item | Value |
|------|-------|
| Problem # | 002 |
| Domain | Storage |
| Difficulty | killer.sh Level |
| Estimated Time | 7 min |
| Namespace | cka-q002 |

## Context

A Job named `backup-job` is running in namespace `cka-q002`. This Job requires persistent storage to save backup data. The cluster has a `local-path` provisioner installed.

> Note: You may refer to the official documentation at https://kubernetes.io/docs.

## Tasks

1. Create a StorageClass with the following spec:
   - Name: `local-backup`
   - provisioner: `rancher.io/local-path`
   - reclaimPolicy: `Retain`
   - volumeBindingMode: `WaitForFirstConsumer`

2. Create a PVC in namespace `cka-q002` with the following spec:
   - Name: `backup-pvc`
   - storageClassName: `local-backup`
   - Access mode: `ReadWriteOnce`
   - Requested capacity: `50Mi`

3. Delete Job `backup-job` and create a new Job with the following spec:
   - Name: `backup-job`
   - Image: `busybox:1.36`
   - Command: `sh -c "echo backup-$(date +%Y%m%d) > /backup/latest.txt && cat /backup/latest.txt"`
   - Mount PVC `backup-pvc` at `/backup`
   - restartPolicy: `Never`
   - backoffLimit: `0`

## Expected Outcome

- `kubectl get sc local-backup` shows provisioner as `rancher.io/local-path`
- `kubectl -n cka-q002 get pvc backup-pvc` shows STATUS as `Bound`
- Job `backup-job` completes successfully (Completed)

<details>
<summary>Hint 1</summary>

The StorageClass setting `volumeBindingMode: WaitForFirstConsumer` delays PV binding until a Pod using the PVC is scheduled.

</details>

<details>
<summary>Hint 2</summary>

Adding a volume to a Job:
```yaml
spec:
  template:
    spec:
      volumes:
      - name: backup-vol
        persistentVolumeClaim:
          claimName: backup-pvc
      containers:
      - volumeMounts:
        - name: backup-vol
          mountPath: /backup
```

</details>
