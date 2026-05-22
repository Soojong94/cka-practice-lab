# Problem 089: Gateway API - HTTPRoute 경로 라우팅

| 항목 | 값 |
|------|-----|
| 문제 번호 | 089 |
| 도메인 | Services & Networking |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 10분 |
| 네임스페이스 | cka-q089 |

## Context

네임스페이스 `cka-q089`에 Gateway `api-gateway`와 두 개의 Service (`svc-v1`, `svc-v2`)가 동작 중입니다. URL 경로에 따라 트래픽을 다른 Service로 라우팅하는 HTTPRoute를 구성해야 합니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. 네임스페이스 `cka-q089`에 HTTPRoute `api-routes`를 생성하세요:
   - parentRefs: `api-gateway` Gateway 참조

2. 경로 규칙 1: `/v1` 경로 → `svc-v1` Service (port 80)
   - pathMatch type: `PathPrefix`
   - value: `/v1`

3. 경로 규칙 2: `/v2` 경로 → `svc-v2` Service (port 80)
   - pathMatch type: `PathPrefix`
   - value: `/v2`

4. HTTPRoute가 올바르게 생성되었는지 확인하세요.

## Expected Outcome

- `kubectl -n cka-q089 get httproute api-routes` 존재
- HTTPRoute에 /v1 → svc-v1, /v2 → svc-v2 규칙 포함
- parentRefs가 api-gateway를 참조

<details>
<summary>힌트 1</summary>

HTTPRoute의 `spec.parentRefs`로 Gateway를 참조합니다. `spec.rules`에 경로 매칭 규칙을 정의합니다.

</details>

<details>
<summary>힌트 2</summary>

```yaml
rules:
- matches:
  - path:
      type: PathPrefix
      value: /v1
  backendRefs:
  - name: svc-v1
    port: 80
```

</details>

<details>
<summary>힌트 3</summary>

여러 경로 규칙은 `rules` 배열에 별도의 항목으로 추가합니다.

</details>
