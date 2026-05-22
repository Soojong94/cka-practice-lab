# Problem 018: CoreDNS 설정 오류 수정

| 항목 | 값 |
|------|-----|
| 문제 번호 | 018 |
| 도메인 | Troubleshooting |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 10분 |
| 네임스페이스 | cka-q018 |

## Context

클러스터의 CoreDNS가 비정상 동작하여 Pod 간 DNS 해석이 실패하고 있습니다. CoreDNS ConfigMap의 Corefile에 문법 오류가 있어 CoreDNS Pod가 정상적으로 시작되지 않습니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. CoreDNS Pod의 상태를 확인하세요. (`kube-system` 네임스페이스)

2. CoreDNS Pod의 로그를 확인하여 설정 오류를 파악하세요.

3. `kube-system` 네임스페이스의 ConfigMap `coredns`의 Corefile을 수정하세요.
   - `kubernetes` 블록의 닫는 중괄호(`}`)가 누락되어 있습니다.

4. CoreDNS Pod를 재시작하여 정상 동작을 확인하세요.

## Expected Outcome

- CoreDNS Pod가 모두 Running 상태
- DNS 해석이 정상 동작 (예: `nslookup kubernetes.default.svc.cluster.local`)
- CoreDNS Deployment의 모든 레플리카가 Ready

<details>
<summary>힌트 1</summary>

```bash
kubectl -n kube-system get pods -l k8s-app=kube-dns
kubectl -n kube-system logs -l k8s-app=kube-dns
```

</details>

<details>
<summary>힌트 2</summary>

```bash
kubectl -n kube-system get configmap coredns -o yaml
```

Corefile에서 `kubernetes cluster.local` 블록 뒤에 닫는 `}`가 빠져 있습니다.

</details>

<details>
<summary>힌트 3</summary>

```bash
kubectl -n kube-system edit configmap coredns
# kubernetes 블록에 닫는 } 추가:
#   kubernetes cluster.local in-addr.arpa ip6.arpa {
#      pods insecure
#      fallthrough in-addr.arpa ip6.arpa
#      ttl 30
#   }    ← 이 줄 추가

kubectl -n kube-system rollout restart deployment coredns
```

</details>
