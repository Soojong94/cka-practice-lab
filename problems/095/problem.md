# Problem 095: CoreDNS 커스텀 도메인 추가

| 항목 | 값 |
|------|-----|
| 문제 번호 | 095 |
| 도메인 | Services & Networking |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 12분 |
| 네임스페이스 | cka-q095 |

## Context

클러스터의 CoreDNS 설정을 수정하여 커스텀 도메인 `custom.local`을 추가해야 합니다. 이 도메인으로 Service를 해석할 수 있어야 합니다. CoreDNS ConfigMap의 백업이 `cka-q095` 네임스페이스에 `coredns-backup`으로 저장되어 있습니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. CoreDNS ConfigMap (`kube-system/coredns`)을 수정하여 `custom.local` 도메인을 추가하세요:
   - `custom.local` 도메인에 대한 요청이 클러스터 내부 DNS로 해석되도록 설정
   - rewrite 규칙 사용: `custom.local` → `cluster.local`로 변환

2. CoreDNS Pod를 재시작하세요:
   - `kubectl -n kube-system rollout restart deployment coredns`

3. CoreDNS Pod가 정상 Running 상태인지 확인하세요.

4. 테스트: `cka-q095` 네임스페이스에서 `test-svc.cka-q095.svc.custom.local`이 해석되는지 확인하세요.

## Expected Outcome

- CoreDNS ConfigMap에 custom.local 관련 설정 포함
- CoreDNS Pod가 Running 상태
- custom.local 도메인으로 DNS 해석 가능

<details>
<summary>힌트 1</summary>

CoreDNS ConfigMap 확인: `kubectl -n kube-system get configmap coredns -o yaml`

</details>

<details>
<summary>힌트 2</summary>

CoreDNS rewrite 플러그인을 사용하여 도메인을 변환할 수 있습니다:
```
rewrite name regex (.+)\.custom\.local {1}.cluster.local
```

</details>

<details>
<summary>힌트 3</summary>

CoreDNS Corefile에 rewrite 규칙을 kubernetes 플러그인 앞에 추가합니다. 수정 후 반드시 CoreDNS를 재시작해야 합니다.

</details>
