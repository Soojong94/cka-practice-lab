# Problem 048: CronJob 스케줄링

| 항목 | 값 |
|------|-----|
| 문제 번호 | 048 |
| 도메인 | Workloads & Scheduling |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 7분 |
| 네임스페이스 | cka-q048 |

## Context

네임스페이스 `cka-q048`에 주기적으로 백업 작업을 수행하는 CronJob을 생성해야 합니다. 적절한 히스토리 제한과 동시 실행 정책을 설정하세요.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. 네임스페이스 `cka-q048`에 다음 스펙으로 CronJob을 생성하세요:
   - 이름: `backup-cron`
   - 스케줄: `*/5 * * * *` (매 5분마다)
   - 이미지: `busybox`
   - 명령: `echo backup-done`

2. 다음 설정을 추가하세요:
   - successfulJobsHistoryLimit: `3`
   - failedJobsHistoryLimit: `1`
   - concurrencyPolicy: `Forbid`

3. CronJob이 올바르게 생성되었는지 확인하세요.

4. 수동으로 Job을 한 번 실행하여 정상 동작을 확인하세요:
   - `kubectl -n cka-q048 create job --from=cronjob/backup-cron backup-test`

## Expected Outcome

- CronJob `backup-cron`이 올바른 스케줄과 설정으로 존재
- concurrencyPolicy가 Forbid로 설정됨
- 히스토리 제한이 올바르게 설정됨

<details>
<summary>힌트 1</summary>

CronJob 생성 명령:
```bash
kubectl -n cka-q048 create cronjob backup-cron --image=busybox --schedule="*/5 * * * *" -- echo backup-done
```
이후 `kubectl edit`으로 추가 설정을 수정합니다.

</details>

<details>
<summary>힌트 2</summary>

concurrencyPolicy 옵션:
- `Allow`: 동시 실행 허용 (기본값)
- `Forbid`: 이전 Job이 완료되지 않으면 새 Job 생성 안 함
- `Replace`: 이전 Job을 취소하고 새 Job 생성

</details>

<details>
<summary>힌트 3</summary>

YAML로 직접 생성:
```yaml
spec:
  schedule: "*/5 * * * *"
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 1
  concurrencyPolicy: Forbid
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: busybox
            command: ["echo", "backup-done"]
          restartPolicy: OnFailure
```

</details>
