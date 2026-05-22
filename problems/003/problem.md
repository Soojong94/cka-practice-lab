# Problem 003: PV Reclaim Policy 변경 및 검증

| 항목 | 값 |
|------|-----|
| 문제 번호 | 003 |
| 도메인 | Storage |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 6분 |
| 네임스페이스 | cka-q003 |

## Context

네임스페이스 `cka-q003`에 `data-writer` Pod가 PVC `data-pvc`를 통해 PV `cka-q003-data-pv`를 사용하고 있습니다. 현재 PV의 reclaimPolicy가 `Delete`로 설정되어 있어, PVC 삭제 시 데이터가 유실될 위험이 있습니다.

운영팀에서 데이터 보존을 위해 reclaimPolicy를 변경하고, 안전하게 PVC를 해제하도록 요청했습니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. PV `cka-q003-data-pv`의 현재 reclaimPolicy를 확인하세요.

2. PV `cka-q003-data-pv`의 reclaimPolicy를 `Retain`으로 변경하세요.

3. Pod `data-writer`를 삭제하세요.

4. PVC `data-pvc`를 삭제하세요.

5. PV `cka-q003-data-pv`의 STATUS가 `Released`인지 확인하세요 (Retain 정책으로 인해 PV가 삭제되지 않고 Released 상태로 남아야 합니다).

## Expected Outcome

- PV `cka-q003-data-pv`의 reclaimPolicy가 `Retain`
- PVC `data-pvc`가 삭제됨
- PV `cka-q003-data-pv`가 `Released` 상태로 남아있음

<details>
<summary>힌트 1</summary>

PV의 reclaimPolicy는 `kubectl patch`로 변경할 수 있습니다:
```bash
kubectl patch pv <pv-name> -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'
```

</details>

<details>
<summary>힌트 2</summary>

PVC를 삭제하면 PV의 상태가 변합니다. reclaimPolicy가 `Retain`이면 PV는 `Released` 상태로 남고, `Delete`이면 PV도 함께 삭제됩니다.

</details>
