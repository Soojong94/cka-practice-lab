# Problem 086: NetworkPolicy Egress 규칙

| 항목 | 값 |
|------|-----|
| 문제 번호 | 086 |
| 도메인 | Services & Networking |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 10분 |
| 네임스페이스 | cka-q086 |

## Context

네임스페이스 `cka-q086`에 `app` Pod와 `db` Pod가 동작 중입니다. 보안 정책에 따라 `app` Pod의 아웃바운드 트래픽을 제한해야 합니다. `app` Pod는 `db` Pod의 port 5432와 DNS(port 53)에만 접근할 수 있어야 합니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. 네임스페이스 `cka-q086`에 다음 스펙으로 NetworkPolicy를 생성하세요:
   - 이름: `app-egress`
   - 적용 대상: label `role: app`인 Pod
   - policyTypes: `Egress`

2. Egress 규칙 1: `db` Pod (label `role: db`)로 TCP port 5432 허용

3. Egress 규칙 2: kube-dns로 UDP/TCP port 53 허용 (namespaceSelector로 kube-system 선택)

4. 위 규칙 외의 모든 egress 트래픽은 차단되어야 합니다.

## Expected Outcome

- NetworkPolicy `app-egress`가 존재
- egress 규칙에 db Pod port 5432와 DNS port 53이 포함
- policyTypes에 Egress 포함

<details>
<summary>힌트 1</summary>

Egress NetworkPolicy에서 DNS를 허용하지 않으면 Pod가 Service 이름을 해석할 수 없습니다. kube-dns는 `kube-system` 네임스페이스에 있습니다.

</details>

<details>
<summary>힌트 2</summary>

kube-system 네임스페이스를 선택하려면 namespaceSelector를 사용합니다:
```yaml
- to:
  - namespaceSelector:
      matchLabels:
        kubernetes.io/metadata.name: kube-system
  ports:
  - protocol: UDP
    port: 53
  - protocol: TCP
    port: 53
```

</details>

<details>
<summary>힌트 3</summary>

두 개의 egress 규칙을 별도의 `- to:` 블록으로 작성합니다. 하나는 db Pod용, 하나는 DNS용입니다.

</details>
