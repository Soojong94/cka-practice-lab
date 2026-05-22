# Problem 027: 정답 풀이

## Step 1: 현재 rollout 상태 확인

```bash
kubectl -n cka-q027 rollout status deployment/web-deploy
# 출력: Waiting for deployment "web-deploy" rollout to finish...
# (타임아웃 발생 - 새 Pod가 시작되지 않음)
```

## Step 2: Pod 상태 확인

```bash
kubectl -n cka-q027 get pods
# 일부 Pod가 ImagePullBackOff 또는 ErrImagePull 상태
```

## Step 3: rollout 히스토리 확인

```bash
kubectl -n cka-q027 rollout history deployment/web-deploy
# REVISION  CHANGE-CAUSE
# 1         <none>
# 2         <none>

kubectl -n cka-q027 rollout history deployment/web-deploy --revision=1
# 이미지: nginx:alpine (정상 버전)

kubectl -n cka-q027 rollout history deployment/web-deploy --revision=2
# 이미지: nginx:nonexistent-version-v999 (실패 버전)
```

## Step 4: 이전 버전으로 롤백

```bash
kubectl -n cka-q027 rollout undo deployment/web-deploy
# 또는
kubectl -n cka-q027 rollout undo deployment/web-deploy --to-revision=1
```

## Step 5: 롤백 완료 확인

```bash
kubectl -n cka-q027 rollout status deployment/web-deploy
# 출력: deployment "web-deploy" successfully rolled out

kubectl -n cka-q027 get pods
# 3개 Pod 모두 Running, READY 1/1
```

## 검증

```bash
kubectl -n cka-q027 get deployment web-deploy
kubectl -n cka-q027 get deployment web-deploy -o jsonpath='{.spec.template.spec.containers[0].image}'
# 출력: nginx:alpine
```
