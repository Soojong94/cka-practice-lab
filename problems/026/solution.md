# Problem 026: 정답 풀이

## Step 1: 문제 진단

```bash
# Pod 상태 확인
kubectl -n cka-q026 get pods

# app-crash: CrashLoopBackOff
kubectl -n cka-q026 describe pod app-crash
# Events에서 "Back-off restarting failed container" 확인
# command가 "exit 1"로 설정되어 즉시 종료됨

# app-imagepull: ImagePullBackOff
kubectl -n cka-q026 describe pod app-imagepull
# Events에서 "Failed to pull image" 확인
# 이미지 "nginx:nonexistent-tag-v999"가 존재하지 않음
```

## Step 2: app-crash 수정

```bash
# Pod 삭제
kubectl -n cka-q026 delete pod app-crash --grace-period=0 --force

# 올바른 command로 재생성
kubectl -n cka-q026 run app-crash --image=nginx:alpine \
  --labels=app=app-crash \
  --command -- /bin/sh -c "sleep 3600"
```

## Step 3: app-imagepull 수정

```bash
# Pod 삭제
kubectl -n cka-q026 delete pod app-imagepull --grace-period=0 --force

# 올바른 이미지로 재생성
kubectl -n cka-q026 run app-imagepull --image=nginx:alpine \
  --labels=app=app-imagepull \
  --command -- /bin/sh -c "sleep 3600"
```

## 검증

```bash
kubectl -n cka-q026 get pods
# 두 Pod 모두 Running, READY 1/1 확인
```
