# Problem 083: DNS FQDN 해석 (일반/Headless)

| 항목 | 값 |
|------|-----|
| 문제 번호 | 083 |
| 도메인 | Services & Networking |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 10분 |
| 네임스페이스 | cka-q083 |

## Context

네임스페이스 `cka-q083`에 일반 ClusterIP Service `normal-svc`와 Headless Service `headless-svc`가 각각의 Deployment와 함께 동작 중입니다. 두 Service의 DNS 해석 방식 차이를 이해하고 검증해야 합니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. 테스트용 Pod `dns-test`를 생성하세요 (이미지: `busybox:1.36`, 명령: `sleep 3600`).

2. `dns-test` Pod에서 `normal-svc`의 FQDN을 nslookup으로 해석하세요:
   - FQDN: `normal-svc.cka-q083.svc.cluster.local`
   - 결과: ClusterIP 1개가 반환되어야 함

3. `dns-test` Pod에서 `headless-svc`의 FQDN을 nslookup으로 해석하세요:
   - FQDN: `headless-svc.cka-q083.svc.cluster.local`
   - 결과: 개별 Pod IP들이 반환되어야 함

4. 결과를 ConfigMap `dns-result`에 저장하세요:
   - key `normal-fqdn`: `normal-svc.cka-q083.svc.cluster.local`
   - key `headless-fqdn`: `headless-svc.cka-q083.svc.cluster.local`
   - key `normal-resolves-to`: `clusterip` (ClusterIP로 해석됨을 표시)
   - key `headless-resolves-to`: `pod-ips` (Pod IP들로 해석됨을 표시)

## Expected Outcome

- `dns-test` Pod에서 nslookup 성공
- ConfigMap `dns-result`에 올바른 FQDN과 해석 결과 저장

<details>
<summary>힌트 1</summary>

Kubernetes Service의 FQDN 형식: `<service-name>.<namespace>.svc.cluster.local`

</details>

<details>
<summary>힌트 2</summary>

일반 ClusterIP Service는 DNS 조회 시 Service의 ClusterIP를 반환하고, Headless Service(clusterIP: None)는 각 Pod의 IP를 직접 반환합니다.

</details>

<details>
<summary>힌트 3</summary>

```bash
kubectl -n cka-q083 exec dns-test -- nslookup normal-svc.cka-q083.svc.cluster.local
kubectl -n cka-q083 exec dns-test -- nslookup headless-svc.cka-q083.svc.cluster.local
```

</details>
