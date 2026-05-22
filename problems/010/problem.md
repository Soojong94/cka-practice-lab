# Problem 010: PVC Binding 트러블슈팅

| 항목 | 값 |
|------|-----|
| 문제 번호 | 010 |
| 도메인 | Storage / Troubleshooting |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 8분 |
| 네임스페이스 | cka-q010 |

## Context

네임스페이스 `cka-q010`에 PVC `debug-pvc`가 생성되어 있지만 `Pending` 상태에 머물러 있습니다. 클러스터에 PV `debug-pv`가 존재하지만 PVC와 바인딩되지 않고 있습니다.

PVC와 PV의 설정을 비교하여 바인딩 실패 원인을 찾고 수정하세요.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. PV `debug-pv`의 스펙을 확인하세요:
   - storageClassName, accessModes, capacity를 기록하세요.

2. PVC `debug-pvc`의 스펙을 확인하고 PV와 비교하세요:
   - storageClassName이 PV와 일치하는지 확인
   - accessModes가 PV와 일치하는지 확인

3. PVC의 `storageClassName`을 PV와 일치하도록 수정하세요.
   - PVC의 storageClassName은 immutable이므로 삭제 후 재생성이 필요합니다.

4. PVC의 `accessModes`를 PV와 일치하도록 수정하세요.
   - PV: `ReadWriteOnce` / PVC(현재): `ReadWriteMany`

5. PVC `debug-pvc`가 PV `debug-pv`에 바인딩(Bound)되었는지 확인하세요.

## Expected Outcome

- `kubectl -n cka-q010 get pvc debug-pvc` 실행 시 STATUS가 `Bound`
- PVC가 PV `debug-pv`에 바인딩됨
- storageClassName과 accessModes가 PV와 PVC 간 일치

<details>
<summary>힌트 1</summary>

PVC가 Pending인 이유를 확인하려면:
```bash
kubectl -n cka-q010 describe pvc debug-pvc
```
Events 섹션에서 바인딩 실패 원인을 확인할 수 있습니다.

</details>

<details>
<summary>힌트 2</summary>

PV와 PVC가 바인딩되려면 다음 조건이 모두 일치해야 합니다:
- storageClassName
- accessModes
- capacity (PV >= PVC)

현재 PV: `storageClassName: manual`, `accessModes: [ReadWriteOnce]`
현재 PVC: `storageClassName: wrong-class`, `accessModes: [ReadWriteMany]`

</details>

<details>
<summary>힌트 3</summary>

PVC의 storageClassName과 accessModes는 변경할 수 없으므로 삭제 후 재생성해야 합니다:
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
