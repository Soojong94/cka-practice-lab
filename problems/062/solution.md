# Problem 062: 정답 풀이

## Step 1: Helm 차트 설치

```bash
helm install web-release bitnami/nginx -n cka-q062
```

## Step 2: 설치 확인

```bash
helm list -n cka-q062
# NAME         NAMESPACE  REVISION  STATUS    CHART         APP VERSION
# web-release  cka-q062   1         deployed  nginx-x.x.x  x.x.x

kubectl -n cka-q062 get all
```

## Step 3: 릴리스 업그레이드 (replicaCount=2)

```bash
helm upgrade web-release bitnami/nginx -n cka-q062 --set replicaCount=2
```

## Step 4: 업그레이드 확인

```bash
# Deployment replicas 확인
kubectl -n cka-q062 get deployment -l app.kubernetes.io/instance=web-release

# Helm history 확인
helm history web-release -n cka-q062
# REVISION  STATUS      DESCRIPTION
# 1         superseded  Install complete
# 2         deployed    Upgrade complete
```

## 검증

```bash
helm list -n cka-q062
kubectl -n cka-q062 get deployment -o wide
```
