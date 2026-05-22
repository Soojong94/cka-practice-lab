# Problem 035: Job/CronJob 실패 분석

| 항목 | 값 |
|------|-----|
| 문제 번호 | 035 |
| 도메인 | Troubleshooting |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 7분 |
| 네임스페이스 | cka-q035 |

## Context

네임스페이스 `cka-q035`에 `data-process`라는 Job이 생성되었으나, 명령어 오류로 인해 반복 실패하고 있습니다. `backoffLimit: 3`이 설정되어 있어 3번 재시도 후 최종 실패 상태가 됩니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. Job `data-process`의 상태를 확인하고 실패 원인을 분석하세요.
   - `kubectl describe job`과 `kubectl logs`를 활용

2. 실패한 기존 Job `data-process`를 삭제하세요.

3. 동일한 이름 `data-process`로 새 Job을 생성하되, 명령어를 수정하세요:
   - 올바른 명령: `echo 'Processing data...' && echo 'Done!' && exit 0`
   - backoffLimit: 3 유지
   - restartPolicy: Never

4. 새 Job이 성공적으로 완료되었는지 확인하세요.

## Expected Outcome

- 기존 실패 Job이 삭제됨
- 새 Job `data-process`가 `Complete` 상태
- Job의 Pod가 `Completed` 상태

<details>
<summary>힌트 1</summary>

`kubectl -n cka-q035 describe job data-process`로 실패 횟수와 이유를 확인합니다.
`kubectl -n cka-q035 logs job/data-process`로 로그를 확인합니다.

</details>

<details>
<summary>힌트 2</summary>

기존 Job 삭제:
```bash
kubectl -n cka-q035 delete job data-process
```

</details>

<details>
<summary>힌트 3</summary>

새 Job 생성:
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: data-process
spec:
  backoffLimit: 3
  template:
    spec:
      containers:
      - name: processor
        image: busybox:1.36
        command: ["/bin/sh", "-c", "echo 'Processing data...' && echo 'Done!' && exit 0"]
      restartPolicy: Never
```

</details>
