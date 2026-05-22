# Problem 001: Create PV/PVC and Mount to Pod

| Item | Value |
|------|-------|
| Problem # | 001 |
| Domain | Storage |
| Difficulty | killer.sh Level |
| Estimated Time | 8 min |
| Namespace | cka-q001 |

## Context

A Deployment named `safari` is running in namespace `cka-q001`. The operations team has requested that this application's data be stored on persistent storage.

> Note: You may refer to the official documentation at https://kubernetes.io/docs.

## Tasks

1. Create a PersistentVolume with the following spec:
   - Name: `safari-pv`
   - Capacity: `2Gi`
   - Access mode: `ReadWriteOnce`
   - hostPath: `/Volumes/Data`
   - storageClassName not set (empty string `""`)

2. Create a PersistentVolumeClaim in namespace `cka-q001` with the following spec:
   - Name: `safari-pvc`
   - Requested capacity: `2Gi`
   - Access mode: `ReadWriteOnce`
   - storageClassName not set (empty string `""`)

3. Verify that PVC `safari-pvc` is bound to PV `safari-pv`.

4. Modify Deployment `safari` to mount PVC `safari-pvc` at path `/tmp/safari-data`.

## Expected Outcome

- `kubectl get pv safari-pv` shows STATUS as `Bound`
- `kubectl -n cka-q001 get pvc safari-pvc` shows STATUS as `Bound`
- The `/tmp/safari-data` directory is mounted inside the `safari` Pod

<details>
<summary>Hint 1</summary>

For PV and PVC to automatically bind, the accessModes and capacity must match. Setting storageClassName to an empty string (`""`) disables dynamic provisioning and enables manual binding.

</details>

<details>
<summary>Hint 2</summary>

To add a volume to a Deployment, reference the PVC in `spec.template.spec.volumes` and specify the mount path in `spec.template.spec.containers[].volumeMounts`.

```yaml
volumes:
- name: data-volume
  persistentVolumeClaim:
    claimName: safari-pvc
containers:
- volumeMounts:
  - name: data-volume
    mountPath: /tmp/safari-data
```

</details>

<details>
<summary>Hint 3</summary>

You can modify the Deployment using `kubectl -n cka-q001 edit deployment safari` or `kubectl -n cka-q001 patch deployment safari --type=json -p '[...]'`.

</details>
