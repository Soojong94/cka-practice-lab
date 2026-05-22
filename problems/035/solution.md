# Problem 035: 정답 풀이

## Step 1: Job 상태 확인

```bash
kubectl -n cka-q035 get job data-process
kubectl -n cka-q035 describe job data-process
kubectl -n cka-q035 logs job/data-process
```

실패 원인: 명령어가 `exit 1`로 끝나서 항상 실패

## Step 2: 기존 Job 삭제

```bash
kubectl -n cka-q035 delete job data-process
```

## Step 3: 수정된 Job 생성

```bash
kubectl -n cka-q035 apply -f - <<EOF
apiVersion: batch/v1
kind: Job
metadata:
  name: data-process
  namespace: cka-q035
spec:
  backoffLimit: 3
  template:
    spec:
      containers:
      - name: processor
        image: busybox:1.36
        command: ["/bin/sh", "-c", "echo 'Processing data...' && echo 'Done!' && exit 0"]
      restartPolicy: Never
EOF
```

## Step 4: 완료 확인

```bash
kubectl -n cka-q035 get job data-process
# COMPLETIONS: 1/1

kubectl -n cka-q035 get pods -l job-name=data-process
# STATUS: Completed
```

## 검증

```bash
kubectl -n cka-q035 get job data-process -o jsonpath='{.status.succeeded}'
# 1
```
