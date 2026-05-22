# Problem 049: 정답 풀이

## Step 1: Rolling Update 전략 설정

```bash
kubectl -n cka-q049 patch deployment web -p '{"spec":{"strategy":{"type":"RollingUpdate","rollingUpdate":{"maxSurge":1,"maxUnavailable":0}}}}'
```

## Step 2: 이미지 업데이트

```bash
kubectl -n cka-q049 set image deployment/web nginx=nginx:1.25-alpine
```

## Step 3: 롤아웃 상태 확인

```bash
kubectl -n cka-q049 rollout status deployment/web
```

## Step 4: 롤백

```bash
kubectl -n cka-q049 rollout undo deployment/web
```

## Step 5: 확인

```bash
# 현재 이미지 확인 (1.24-alpine으로 돌아감)
kubectl -n cka-q049 get deployment web -o jsonpath='{.spec.template.spec.containers[0].image}'

# 롤아웃 히스토리 확인
kubectl -n cka-q049 rollout history deployment/web

# Deployment 상태 확인
kubectl -n cka-q049 get deployment web
```

## 핵심 개념

- maxSurge: 업데이트 중 추가로 생성할 수 있는 Pod 수 (또는 비율)
- maxUnavailable: 업데이트 중 사용 불가능한 Pod 수 (또는 비율)
- maxSurge=1, maxUnavailable=0: 항상 4개 이상의 Pod가 가용 (무중단)
- `rollout undo`: 이전 리비전으로 롤백
- `rollout history`: 리비전 히스토리 확인
- `rollout undo --to-revision=N`: 특정 리비전으로 롤백
