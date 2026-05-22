# Problem 048: 정답 풀이

## Step 1: CronJob 생성

```bash
kubectl -n cka-q048 apply -f - <<EOF
apiVersion: batch/v1
kind: CronJob
metadata:
  name: backup-cron
  namespace: cka-q048
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
EOF
```

## Step 2: 수동 Job 실행으로 테스트

```bash
kubectl -n cka-q048 create job --from=cronjob/backup-cron backup-test
```

## Step 3: 확인

```bash
# CronJob 상태 확인
kubectl -n cka-q048 get cronjob backup-cron

# Job 실행 결과 확인
kubectl -n cka-q048 get jobs
kubectl -n cka-q048 logs job/backup-test
```

## 핵심 개념

- CronJob: 주기적으로 Job을 생성하는 리소스
- schedule: cron 형식 (분 시 일 월 요일)
- concurrencyPolicy: Allow(기본), Forbid, Replace
- successfulJobsHistoryLimit: 성공한 Job 보관 수
- failedJobsHistoryLimit: 실패한 Job 보관 수
- `kubectl create job --from=cronjob/<name>`: 수동으로 즉시 실행
