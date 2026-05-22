# Problem 018: 정답 풀이

## Step 1: CoreDNS Pod 상태 확인

```bash
kubectl -n kube-system get pods -l k8s-app=kube-dns
```

Pod가 CrashLoopBackOff 또는 Error 상태임을 확인합니다.

## Step 2: CoreDNS 로그 확인

```bash
kubectl -n kube-system logs -l k8s-app=kube-dns --tail=20
```

Corefile 파싱 에러를 확인할 수 있습니다.

## Step 3: CoreDNS ConfigMap 수정

```bash
kubectl -n kube-system edit configmap coredns
```

수정 전 (kubernetes 블록에 닫는 중괄호 누락):
```
    kubernetes cluster.local in-addr.arpa ip6.arpa {
       pods insecure
       fallthrough in-addr.arpa ip6.arpa
       ttl 30

    prometheus :9153
```

수정 후:
```
    kubernetes cluster.local in-addr.arpa ip6.arpa {
       pods insecure
       fallthrough in-addr.arpa ip6.arpa
       ttl 30
    }
    prometheus :9153
```

## Step 4: CoreDNS 재시작

```bash
kubectl -n kube-system rollout restart deployment coredns
kubectl -n kube-system rollout status deployment coredns
```

## Step 5: DNS 동작 확인

```bash
kubectl -n cka-q018 run dns-test --image=busybox:1.36 --restart=Never --rm -it -- nslookup kubernetes.default.svc.cluster.local
```

## 검증

```bash
kubectl -n kube-system get pods -l k8s-app=kube-dns
# 모든 Pod가 Running 상태인지 확인
```
