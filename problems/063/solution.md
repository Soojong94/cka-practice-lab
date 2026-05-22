# Problem 063: 정답 풀이

## Step 1: 현재 릴리스 상태 확인

```bash
helm list -n cka-q063
helm get values custom-app -n cka-q063
kubectl -n cka-q063 get svc
```

## Step 2: 릴리스 업그레이드

```bash
helm upgrade custom-app bitnami/nginx -n cka-q063 \
  --set service.type=NodePort \
  --set commonLabels.team=platform
```

## Step 3: 확인

```bash
# Service 타입 확인
kubectl -n cka-q063 get svc -l app.kubernetes.io/instance=custom-app

# Deployment 레이블 확인
kubectl -n cka-q063 get deployment -l app.kubernetes.io/instance=custom-app --show-labels

# Helm values 확인
helm get values custom-app -n cka-q063

# Helm history 확인
helm history custom-app -n cka-q063
```

## 검증

```bash
kubectl -n cka-q063 get svc -o jsonpath='{.items[0].spec.type}'
kubectl -n cka-q063 get deployment -o jsonpath='{.items[0].metadata.labels.team}'
```
