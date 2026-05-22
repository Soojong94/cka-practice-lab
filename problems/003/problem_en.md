# Problem 003: Change and Verify PV Reclaim Policy

| Item | Value |
|------|-------|
| Problem # | 003 |
| Domain | Storage |
| Difficulty | killer.sh Level |
| Estimated Time | 6 min |
| Namespace | cka-q003 |

## Context

In namespace `cka-q003`, a Pod `data-writer` is using PV `cka-q003-data-pv` through PVC `data-pvc`. The PV's reclaimPolicy is currently set to `Delete`, which risks data loss when the PVC is deleted.

The operations team has requested that the reclaimPolicy be changed to preserve data, and that the PVC be safely released.

> Note: You may refer to the official documentation at https://kubernetes.io/docs.

## Tasks

1. Check the current reclaimPolicy of PV `cka-q003-data-pv`.

2. Change the reclaimPolicy of PV `cka-q003-data-pv` to `Retain`.

3. Delete Pod `data-writer`.

4. Delete PVC `data-pvc`.

5. Verify that PV `cka-q003-data-pv` STATUS is `Released` (due to the Retain policy, the PV should remain in Released state instead of being deleted).

## Expected Outcome

- PV `cka-q003-data-pv` reclaimPolicy is `Retain`
- PVC `data-pvc` is deleted
- PV `cka-q003-data-pv` remains in `Released` state

<details>
<summary>Hint 1</summary>

You can change the PV's reclaimPolicy using `kubectl patch`:
```bash
kubectl patch pv <pv-name> -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'
```

</details>

<details>
<summary>Hint 2</summary>

When a PVC is deleted, the PV's status changes. If reclaimPolicy is `Retain`, the PV remains in `Released` state. If it's `Delete`, the PV is also deleted.

</details>
