# Problem 096: 정답 풀이

## Step 1: FQDN 확인

크로스 네임스페이스 Service 접근 FQDN:
```
svc-b.cka-q096-b.svc.cluster.local
```

## Step 2: pod-a에서 curl 테스트

```bash
kubectl -n cka-q096-a exec pod-a -- curl -s http://svc-b.cka-q096-b.svc.cluster.local
```

## Step 3: ConfigMap 생성

```bash
RESULT=$(kubectl -n cka-q096-a exec pod-a -- curl -s http://svc-b.cka-q096-b.svc.cluster.local)

kubectl -n cka-q096-a create configmap cross-ns-result \
  --from-literal=fqdn="svc-b.cka-q096-b.svc.cluster.local" \
  --from-literal=curl-command="curl -s http://svc-b.cka-q096-b.svc.cluster.local" \
  --from-literal=result="$RESULT"
```

## 검증

```bash
kubectl -n cka-q096-a get configmap cross-ns-result -o yaml
```
