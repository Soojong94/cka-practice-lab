# Problem 004: PV Capacity Expansion (Volume Expansion)

| Item | Value |
|------|-------|
| Problem # | 004 |
| Domain | Storage |
| Difficulty | killer.sh Level |
| Estimated Time | 7 min |
| Namespace | cka-q004 |

## Context

In namespace `cka-q004`, a Pod named `volume-pod` is running and has PVC `data-pvc` (1Gi) mounted at `/data`. The StorageClass `expandable-sc` is configured to allow volume expansion.

The operations team received a disk space warning and needs to expand the PVC capacity.

> Note: You may refer to the official documentation at https://kubernetes.io/docs.

## Tasks

1. Verify that StorageClass `expandable-sc` allows volume expansion.
   - `allowVolumeExpansion: true` must be set.

2. Confirm that PVC `data-pvc` currently has a capacity of `1Gi`.

3. While Pod `volume-pod` is still running, expand PVC `data-pvc` from `1Gi` to `2Gi`.
   - The expansion must be done online without deleting the Pod.

4. Verify that PVC's `.spec.resources.requests.storage` has been changed to `2Gi`.

5. Verify that the PVC's Conditions show `FileSystemResizePending` or that the capacity has been updated to `2Gi`.

## Expected Outcome

- `kubectl -n cka-q004 get pvc data-pvc` shows CAPACITY as `2Gi`
- Pod `volume-pod` remains in Running state
- PVC's spec.resources.requests.storage is `2Gi`

<details>
<summary>Hint 1</summary>

To expand a PVC's capacity, use `kubectl edit pvc` or `kubectl patch pvc`. The StorageClass must have `allowVolumeExpansion: true` set.

</details>

<details>
<summary>Hint 2</summary>

```bash
kubectl -n cka-q004 patch pvc data-pvc -p '{"spec":{"resources":{"requests":{"storage":"2Gi"}}}}'
```

</details>

<details>
<summary>Hint 3</summary>

After volume expansion, the actual filesystem resize is performed automatically depending on the CSI driver. You can verify with `kubectl -n cka-q004 get pvc data-pvc -o jsonpath='{.status.capacity.storage}'`.

</details>
