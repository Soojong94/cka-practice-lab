# Problem 044: 정답 풀이

## Step 1: prod-app 생성 (toleration 포함)

```bash
kubectl -n cka-q044 apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: prod-app
  namespace: cka-q044
spec:
  tolerations:
  - key: "env"
    operator: "Equal"
    value: "production"
    effect: "NoSchedule"
  containers:
  - name: nginx
    image: nginx:1-alpine
EOF
```

## Step 2: dev-app 생성 (toleration 없음)

```bash
kubectl -n cka-q044 apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: dev-app
  namespace: cka-q044
spec:
  containers:
  - name: nginx
    image: nginx:1-alpine
EOF
```

## Step 3: 상태 확인 (prod-app Running, dev-app Pending)

```bash
kubectl -n cka-q044 get pods
```

## Step 4: Taint 제거

```bash
# taint가 걸린 모든 노드에서 제거
kubectl taint nodes --all env=production:NoSchedule-
```

## Step 5: dev-app Running 확인

```bash
# 잠시 대기 후 확인
sleep 5
kubectl -n cka-q044 get pods
```

## 핵심 개념

- Taint: 노드에 설정하여 특정 Pod만 스케줄되도록 제한
- Toleration: Pod에 설정하여 특정 taint를 허용
- NoSchedule: 새로운 Pod 스케줄링 방지 (기존 Pod에는 영향 없음)
- NoExecute: 기존 Pod도 축출
- PreferNoSchedule: 가능하면 스케줄하지 않음 (소프트 규칙)
