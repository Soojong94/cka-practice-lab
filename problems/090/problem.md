# Problem 090: Gateway API - 헤더 기반 라우팅

| 항목 | 값 |
|------|-----|
| 문제 번호 | 090 |
| 도메인 | Services & Networking |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 10분 |
| 네임스페이스 | cka-q090 |

## Context

네임스페이스 `cka-q090`에 Gateway `header-gateway`와 두 개의 Service (`mobile-svc`, `desktop-svc`)가 동작 중입니다. HTTP 요청의 User-Agent 헤더에 따라 트래픽을 다른 Service로 라우팅해야 합니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. 네임스페이스 `cka-q090`에 HTTPRoute `device-route`를 생성하세요:
   - parentRefs: `header-gateway` Gateway 참조

2. 규칙 1: User-Agent 헤더에 "Mobile"이 포함된 요청 → `mobile-svc` (port 80)
   - header match type: `RegularExpression`
   - name: `User-Agent`
   - value: `.*Mobile.*`

3. 규칙 2: 기본 규칙 (매칭 조건 없음) → `desktop-svc` (port 80)

4. HTTPRoute가 올바르게 생성되었는지 확인하세요.

## Expected Outcome

- `kubectl -n cka-q090 get httproute device-route` 존재
- HTTPRoute에 User-Agent 헤더 매칭 규칙 포함
- 기본 라우팅이 desktop-svc로 설정됨

<details>
<summary>힌트 1</summary>

HTTPRoute에서 헤더 매칭은 `matches[].headers[]`로 설정합니다. type은 `Exact` 또는 `RegularExpression`을 사용할 수 있습니다.

</details>

<details>
<summary>힌트 2</summary>

```yaml
rules:
- matches:
  - headers:
    - type: RegularExpression
      name: User-Agent
      value: ".*Mobile.*"
  backendRefs:
  - name: mobile-svc
    port: 80
```

</details>

<details>
<summary>힌트 3</summary>

기본 규칙은 `matches` 없이 `backendRefs`만 지정합니다:
```yaml
- backendRefs:
  - name: desktop-svc
    port: 80
```

</details>
