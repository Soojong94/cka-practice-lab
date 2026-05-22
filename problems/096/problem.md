# Problem 096: Pod 간 통신 테스트 및 디버깅

| 항목 | 값 |
|------|-----|
| 문제 번호 | 096 |
| 도메인 | Services & Networking |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 8분 |
| 네임스페이스 | cka-q096 |

## Context

두 개의 네임스페이스 `cka-q096-a`와 `cka-q096-b`가 있습니다. `cka-q096-a`에 `pod-a`가, `cka-q096-b`에 `pod-b`와 `svc-b` Service가 동작 중입니다. 크로스 네임스페이스 통신을 테스트하고 결과를 기록해야 합니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. `pod-a`에서 `cka-q096-b` 네임스페이스의 `svc-b` Service에 접근하기 위한 FQDN을 확인하세요.

2. `pod-a`에서 해당 FQDN으로 curl 요청을 실행하세요:
   - `curl -s http://svc-b.cka-q096-b.svc.cluster.local`

3. 결과를 ConfigMap `cross-ns-result`에 저장하세요 (네임스페이스: `cka-q096-a`):
   - key `fqdn`: 사용한 FQDN
   - key `curl-command`: 실행한 curl 명령어
   - key `result`: curl 응답 결과 (nginx 기본 페이지 일부)

## Expected Outcome

- ConfigMap `cross-ns-result`가 `cka-q096-a` 네임스페이스에 존재
- FQDN이 `svc-b.cka-q096-b.svc.cluster.local` 형식
- curl 명령과 결과가 올바르게 저장됨

<details>
<summary>힌트 1</summary>

크로스 네임스페이스 Service 접근 FQDN: `<service-name>.<namespace>.svc.cluster.local`

</details>

<details>
<summary>힌트 2</summary>

```bash
kubectl -n cka-q096-a exec pod-a -- curl -s http://svc-b.cka-q096-b.svc.cluster.local
```

</details>

<details>
<summary>힌트 3</summary>

ConfigMap 생성:
```bash
kubectl -n cka-q096-a create configmap cross-ns-result \
  --from-literal=fqdn="svc-b.cka-q096-b.svc.cluster.local" \
  --from-literal=curl-command="curl -s http://svc-b.cka-q096-b.svc.cluster.local" \
  --from-literal=result="$(kubectl -n cka-q096-a exec pod-a -- curl -s http://svc-b.cka-q096-b.svc.cluster.local)"
```

</details>
