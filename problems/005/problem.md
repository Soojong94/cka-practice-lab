# Problem 005: 다중 접근 모드 PV 구성

| 항목 | 값 |
|------|-----|
| 문제 번호 | 005 |
| 도메인 | Storage |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 10분 |
| 네임스페이스 | cka-q005 |

## Context

네임스페이스 `cka-q005`에 두 개의 Pod(`writer-pod`, `reader-pod`)가 동작해야 합니다. 두 Pod는 동일한 볼륨을 공유하여 데이터를 읽고 써야 합니다.

현재 두 Pod는 생성되어 있지 않으며, 공유 스토리지를 구성한 후 Pod를 배포해야 합니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. 다음 스펙으로 PersistentVolume을 생성하세요:
   - 이름: `shared-pv`
   - 용량: `1Gi`
   - 접근 모드: `ReadWriteMany`
   - hostPath: `/tmp/shared-data`
   - storageClassName: `manual`

2. 네임스페이스 `cka-q005`에 다음 스펙으로 PersistentVolumeClaim을 생성하세요:
   - 이름: `shared-pvc`
   - 요청 용량: `1Gi`
   - 접근 모드: `ReadWriteMany`
   - storageClassName: `manual`

3. PVC `shared-pvc`가 PV `shared-pv`에 바인딩되었는지 확인하세요.

4. 네임스페이스 `cka-q005`에 `writer-pod`를 생성하세요:
   - 이미지: `busybox:1.36`
   - 명령: `sh -c "echo 'hello from writer' > /shared/data.txt && sleep 3600"`
   - PVC `shared-pvc`를 `/shared` 경로에 마운트

5. 네임스페이스 `cka-q005`에 `reader-pod`를 생성하세요:
   - 이미지: `busybox:1.36`
   - 명령: `sh -c "cat /shared/data.txt && sleep 3600"`
   - PVC `shared-pvc`를 `/shared` 경로에 마운트

## Expected Outcome

- PVC `shared-pvc`가 Bound 상태
- `writer-pod`와 `reader-pod` 모두 Running 상태
- `reader-pod`에서 `/shared/data.txt` 파일 읽기 가능

<details>
<summary>힌트 1</summary>

ReadWriteMany(RWX) 접근 모드는 여러 노드에서 동시에 읽기/쓰기가 가능합니다. hostPath는 단일 노드에서만 동작하지만, 시험 환경에서는 RWX 시뮬레이션에 사용됩니다.

</details>

<details>
<summary>힌트 2</summary>

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
<summary>힌트 3</summary>

두 Pod 모두 동일한 PVC를 참조하면 됩니다:

```yaml
volumes:
- name: shared-vol
  persistentVolumeClaim:
    claimName: shared-pvc
```

</details>
