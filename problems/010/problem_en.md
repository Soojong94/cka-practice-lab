# Problem 010: PVC Binding Troubleshooting

| Item | Value |
|------|-------|
| Problem # | 010 |
| Domain | Storage / Troubleshooting |
| Difficulty | killer.sh Level |
| Estimated Time | 8 min |
| Namespace | cka-q010 |

## Context

In namespace `cka-q010`, a PVC `debug-pvc` has been created but remains in `Pending` state. A PV `debug-pv` exists in the cluster but is not binding to the PVC.

Compare the PVC and PV configurations to identify the binding failure cause and fix it.

> Note: You may refer to the official documentation at https://kubernetes.io/docs.

## Tasks

1. Inspect the spec of PV `debug-pv`:
   - Note the storageClassName, accessModes, and capacity.

2. Inspect the spec of PVC `debug-pvc` and compare with the PV:
   - Check if storageClassName matches the PV
   - Check if accessModes match the PV

3. Fix the PVC's `storageClassName` to match the PV.
   - Since PVC storageClassName is immutable, you need to delete and recreate it.

4. Fix the PVC's `accessModes` to match the PV.
   - PV: `ReadWriteOnce` / PVC (current): `ReadWriteMany`

5. Verify that PVC `debug-pvc` is bound to PV `debug-pv`.

## Expected Outcome

- `kubectl -n cka-q010 get pvc debug-pvc` shows STATUS as `Bound`
- PVC is bound to PV `debug-pv`
- storageClassName and accessModes match between PV and PVC

<details>
<summary>Hint 1</summary>

To check why the PVC is Pending:
```bash
kubectl -n cka-q010 describe pvc debug-pvc
```
Check the Events section for binding failure reasons.

</details>

<details>
<summary>Hint 2</summary>

For PV and PVC to bind, all of the following must match:
- storageClassName
- accessModes
- capacity (PV >= PVC)

Current PV: `storageClassName: manual`, `accessModes: [ReadWriteOnce]`
Current PVC: `storageClassName: wrong-class`, `accessModes: [ReadWriteMany]`

</details>

<details>
<summary>Hint 3</summary>

Since PVC storageClassName and accessModes cannot be modified, you must delete and recreate:
```bash
kubectl -n cka-q010 delete pvc debug-pvc
kubectl -n cka-q010 apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: debug-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: manual
  resources:
    requests:
      storage: 2Gi
EOF
```

</details>
