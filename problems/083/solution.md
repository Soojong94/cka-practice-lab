# Problem 083: 정답 풀이

## Step 1: 테스트 Pod 생성

```bash
kubectl -n cka-q083 run dns-test --image=busybox:1.36 --command -- sleep 3600
kubectl -n cka-q083 wait --for=condition=Ready pod/dns-test --timeout=30s
```

## Step 2: 일반 Service DNS 해석

```bash
kubectl -n cka-q083 exec dns-test -- nslookup normal-svc.cka-q083.svc.cluster.local
# ClusterIP 1개가 반환됨
```

## Step 3: Headless Service DNS 해석

```bash
kubectl -n cka-q083 exec dns-test -- nslookup headless-svc.cka-q083.svc.cluster.local
# 개별 Pod IP들이 반환됨
```

## Step 4: ConfigMap 생성

```bash
kubectl -n cka-q083 create configmap dns-result \
  --from-literal=normal-fqdn="normal-svc.cka-q083.svc.cluster.local" \
  --from-literal=headless-fqdn="headless-svc.cka-q083.svc.cluster.local" \
  --from-literal=normal-resolves-to="clusterip" \
  --from-literal=headless-resolves-to="pod-ips"
```

## 검증

```bash
kubectl -n cka-q083 get configmap dns-result -o yaml
```
