# Problem 004: PV 용량 확장 (Volume Expansion)

| 항목 | 값 |
|------|-----|
| 문제 번호 | 004 |
| 도메인 | Storage |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 7분 |
| 네임스페이스 | cka-q004 |

## Context

네임스페이스 `cka-q004`에 `volume-pod`라는 Pod가 동작 중이며, `data-pvc`라는 PVC(1Gi)를 `/data` 경로에 마운트하고 있습니다. StorageClass `expandable-sc`는 볼륨 확장을 허용하도록 설정되어 있습니다.

운영팀에서 디스크 용량 부족 경고를 받아 PVC 용량을 확장해야 합니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. StorageClass `expandable-sc`가 볼륨 확장을 허용하는지 확인하세요.
   - `allowVolumeExpansion: true`가 설정되어 있어야 합니다.

2. PVC `data-pvc`의 현재 용량이 `1Gi`인지 확인하세요.

3. Pod `volume-pod`가 실행 중인 상태에서 PVC `data-pvc`의 요청 용량을 `1Gi`에서 `2Gi`로 확장하세요.
   - Pod를 삭제하지 않고 온라인 상태에서 확장해야 합니다.

4. PVC의 `.spec.resources.requests.storage`가 `2Gi`로 변경되었는지 확인하세요.

5. PVC의 상태(Conditions)에서 `FileSystemResizePending` 또는 용량이 실제로 `2Gi`로 반영되었는지 확인하세요.

## Expected Outcome

- `kubectl -n cka-q004 get pvc data-pvc` 실행 시 CAPACITY가 `2Gi`
- Pod `volume-pod`는 계속 Running 상태
- PVC의 spec.resources.requests.storage가 `2Gi`

<details>
<summary>힌트 1</summary>

PVC의 용량을 확장하려면 `kubectl edit pvc` 또는 `kubectl patch pvc` 명령을 사용합니다. StorageClass에 `allowVolumeExpansion: true`가 설정되어 있어야 합니다.

</details>

<details>
<summary>힌트 2</summary>

```bash
kubectl -n cka-q004 patch pvc data-pvc -p '{"spec":{"resources":{"requests":{"storage":"2Gi"}}}}'
```

</details>

<details>
<summary>힌트 3</summary>

볼륨 확장 후 실제 파일시스템 리사이즈는 CSI 드라이버에 따라 자동으로 수행됩니다. `kubectl -n cka-q004 get pvc data-pvc -o jsonpath='{.status.capacity.storage}'`로 확인할 수 있습니다.

</details>
