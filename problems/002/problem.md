# Problem 002: StorageClass 동적 프로비저닝

| 항목 | 값 |
|------|-----|
| 문제 번호 | 002 |
| 도메인 | Storage |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 7분 |
| 네임스페이스 | cka-q002 |

## Context

네임스페이스 `cka-q002`에 `backup-job`이라는 Job이 실행 중입니다. 이 Job은 백업 데이터를 저장할 영구 스토리지가 필요합니다. 클러스터에 `local-path` provisioner가 설치되어 있습니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. 다음 스펙으로 StorageClass를 생성하세요:
   - 이름: `local-backup`
   - provisioner: `rancher.io/local-path`
   - reclaimPolicy: `Retain`
   - volumeBindingMode: `WaitForFirstConsumer`

2. 네임스페이스 `cka-q002`에 다음 스펙으로 PVC를 생성하세요:
   - 이름: `backup-pvc`
   - storageClassName: `local-backup`
   - 접근 모드: `ReadWriteOnce`
   - 요청 용량: `50Mi`

3. Job `backup-job`을 삭제하고, 아래 스펙으로 새 Job을 생성하세요:
   - 이름: `backup-job`
   - 이미지: `busybox:1.36`
   - 명령어: `sh -c "echo backup-$(date +%Y%m%d) > /backup/latest.txt && cat /backup/latest.txt"`
   - PVC `backup-pvc`를 `/backup` 경로에 마운트
   - restartPolicy: `Never`
   - backoffLimit: `0`

## Expected Outcome

- `kubectl get sc local-backup` 실행 시 provisioner가 `rancher.io/local-path`
- `kubectl -n cka-q002 get pvc backup-pvc` 실행 시 STATUS가 `Bound`
- Job `backup-job`이 성공적으로 완료됨 (Completed)

<details>
<summary>힌트 1</summary>

StorageClass의 `volumeBindingMode: WaitForFirstConsumer`는 PVC를 사용하는 Pod가 스케줄링될 때까지 PV 바인딩을 지연시킵니다.

</details>

<details>
<summary>힌트 2</summary>

Job에 volume을 추가하는 방법:
```yaml
spec:
  template:
    spec:
      volumes:
      - name: backup-vol
        persistentVolumeClaim:
          claimName: backup-pvc
      containers:
      - volumeMounts:
        - name: backup-vol
          mountPath: /backup
```

</details>
