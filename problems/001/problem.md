# Problem 001: PV/PVC 생성 및 Pod 마운트

| 항목 | 값 |
|------|-----|
| 문제 번호 | 001 |
| 도메인 | Storage |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 8분 |
| 네임스페이스 | cka-q001 |

## Context

네임스페이스 `cka-q001`에 `safari`라는 Deployment가 동작 중입니다. 운영팀에서 이 애플리케이션의 데이터를 영구 저장소에 보관하도록 요청했습니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. 다음 스펙으로 PersistentVolume을 생성하세요:
   - 이름: `safari-pv`
   - 용량: `2Gi`
   - 접근 모드: `ReadWriteOnce`
   - hostPath: `/Volumes/Data`
   - storageClassName 설정하지 않음 (빈 문자열 `""`)

2. 네임스페이스 `cka-q001`에 다음 스펙으로 PersistentVolumeClaim을 생성하세요:
   - 이름: `safari-pvc`
   - 요청 용량: `2Gi`
   - 접근 모드: `ReadWriteOnce`
   - storageClassName 설정하지 않음 (빈 문자열 `""`)

3. PVC `safari-pvc`가 PV `safari-pv`에 바인딩되었는지 확인하세요.

4. Deployment `safari`를 수정하여 PVC `safari-pvc`를 `/tmp/safari-data` 경로에 마운트하세요.

## Expected Outcome

- `kubectl get pv safari-pv` 실행 시 STATUS가 `Bound`
- `kubectl -n cka-q001 get pvc safari-pvc` 실행 시 STATUS가 `Bound`
- `safari` Pod 내부에서 `/tmp/safari-data` 디렉토리가 마운트되어 있음

<details>
<summary>힌트 1</summary>

PV와 PVC가 자동으로 바인딩되려면 accessModes와 capacity가 일치해야 합니다. storageClassName을 빈 문자열(`""`)로 설정하면 동적 프로비저닝을 사용하지 않고 수동 바인딩됩니다.

</details>

<details>
<summary>힌트 2</summary>

Deployment에 volume을 추가하려면 `spec.template.spec.volumes`에 PVC를 참조하고, `spec.template.spec.containers[].volumeMounts`에 마운트 경로를 지정합니다.

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
<summary>힌트 3</summary>

`kubectl -n cka-q001 edit deployment safari` 또는 `kubectl -n cka-q001 patch deployment safari --type=json -p '[...]'`로 Deployment를 수정할 수 있습니다.

</details>
