# Problem 005: Multi-Access Mode PV Configuration

| Item | Value |
|------|-------|
| Problem # | 005 |
| Domain | Storage |
| Difficulty | killer.sh Level |
| Estimated Time | 10 min |
| Namespace | cka-q005 |

## Context

In namespace `cka-q005`, two Pods (`writer-pod`, `reader-pod`) need to be running. Both Pods must share the same volume to read and write data.

Currently neither Pod exists. You need to configure shared storage and then deploy the Pods.

> Note: You may refer to the official documentation at https://kubernetes.io/docs.

## Tasks

1. Create a PersistentVolume with the following spec:
   - Name: `shared-pv`
   - Capacity: `1Gi`
   - Access mode: `ReadWriteMany`
   - hostPath: `/tmp/shared-data`
   - storageClassName: `manual`

2. Create a PersistentVolumeClaim in namespace `cka-q005` with the following spec:
   - Name: `shared-pvc`
   - Requested capacity: `1Gi`
   - Access mode: `ReadWriteMany`
   - storageClassName: `manual`

3. Verify that PVC `shared-pvc` is bound to PV `shared-pv`.

4. Create `writer-pod` in namespace `cka-q005`:
   - Image: `busybox:1.36`
   - Command: `sh -c "echo 'hello from writer' > /shared/data.txt && sleep 3600"`
   - Mount PVC `shared-pvc` at `/shared`

5. Create `reader-pod` in namespace `cka-q005`:
   - Image: `busybox:1.36`
   - Command: `sh -c "cat /shared/data.txt && sleep 3600"`
   - Mount PVC `shared-pvc` at `/shared`

## Expected Outcome

- PVC `shared-pvc` is in Bound state
- Both `writer-pod` and `reader-pod` are in Running state
- `reader-pod` can read the `/shared/data.txt` file

<details>
<summary>Hint 1</summary>

ReadWriteMany (RWX) access mode allows simultaneous read/write from multiple nodes. hostPath only works on a single node, but is used to simulate RWX in exam environments.

</details>

<details>
<summary>Hint 2</summary>

```yaml
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
```

</details>

<details>
<summary>Hint 3</summary>

Both Pods simply reference the same PVC:

```yaml
volumes:
- name: shared-vol
  persistentVolumeClaim:
    claimName: shared-pvc
```

</details>
