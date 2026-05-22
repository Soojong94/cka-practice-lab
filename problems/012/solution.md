# Problem 012: 정답 풀이

## Step 1: Deployment 및 Pod 상태 확인

```bash
kubectl -n cka-q012 get deployment web-deploy
kubectl -n cka-q012 get pods
```

Pod들이 ImagePullBackOff 또는 ErrImagePull 상태임을 확인합니다.

## Step 2: 이벤트 확인

```bash
kubectl -n cka-q012 describe pod -l app=web-deploy | grep -A5 Events
```

`Failed to pull image "ngnix:latest"` 에러를 확인할 수 있습니다. 이미지 이름에 오타가 있습니다.

## Step 3: 이미지 수정

```bash
kubectl -n cka-q012 set image deployment/web-deploy nginx=nginx:latest
```

또는:

```bash
kubectl -n cka-q012 edit deployment web-deploy
# image: ngnix:latest → image: nginx:latest 로 수정
```

## Step 4: 롤아웃 확인

```bash
kubectl -n cka-q012 rollout status deployment/web-deploy
kubectl -n cka-q012 get pods
```

## 검증

```bash
kubectl -n cka-q012 get deployment web-deploy
# AVAILABLE이 3인지 확인
```
