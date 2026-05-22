# Problem 095: 정답 풀이

## Step 1: 현재 CoreDNS ConfigMap 확인

```bash
kubectl -n kube-system get configmap coredns -o yaml
```

## Step 2: CoreDNS ConfigMap 수정

```bash
kubectl -n kube-system edit configmap coredns
```

Corefile에 rewrite 규칙 추가 (kubernetes 플러그인 앞에):

```
.:53 {
    errors
    health {
       lameduck 5s
    }
    ready
    rewrite name regex (.+)\.custom\.local {1}.cluster.local
    kubernetes cluster.local in-addr.arpa ip6.arpa {
       pods insecure
       fallthrough in-addr.arpa ip6.arpa
       ttl 30
    }
    prometheus :9153
    forward . /etc/resolv.conf {
       max_concurrent 1000
    }
    cache 30
    loop
    reload
    loadbalance
}
```

## Step 3: CoreDNS 재시작

```bash
kubectl -n kube-system rollout restart deployment coredns
kubectl -n kube-system rollout status deployment coredns
```

## Step 4: DNS 해석 테스트

```bash
kubectl -n cka-q095 run dns-test --image=busybox:1.36 --rm -it --restart=Never \
  -- nslookup test-svc.cka-q095.svc.custom.local
```

## 검증

```bash
kubectl -n kube-system get configmap coredns -o yaml | grep -A5 rewrite
kubectl -n kube-system get pods -l k8s-app=kube-dns
```
