# Problem 091: Ingress 리소스 생성 (경로/호스트 기반)

| 항목 | 값 |
|------|-----|
| 문제 번호 | 091 |
| 도메인 | Services & Networking |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 8분 |
| 네임스페이스 | cka-q091 |

## Context

네임스페이스 `cka-q091`에 두 개의 Deployment와 Service (`app1-svc`, `app2-svc`)가 동작 중입니다. 하나의 호스트에서 URL 경로에 따라 다른 Service로 라우팅하는 Ingress를 구성해야 합니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. 네임스페이스 `cka-q091`에 Ingress `app-ingress`를 생성하세요:
   - host: `app.example.com`

2. 경로 규칙 1:
   - path: `/app1`
   - pathType: `Prefix`
   - backend: `app1-svc` port `80`

3. 경로 규칙 2:
   - path: `/app2`
   - pathType: `Prefix`
   - backend: `app2-svc` port `80`

4. Ingress가 올바르게 생성되었는지 확인하세요.

## Expected Outcome

- `kubectl -n cka-q091 get ingress app-ingress` 존재
- host가 `app.example.com`으로 설정됨
- /app1 → app1-svc, /app2 → app2-svc 경로 규칙 존재
- pathType이 Prefix

<details>
<summary>힌트 1</summary>

Ingress의 `spec.rules[].host`로 호스트를 지정하고, `spec.rules[].http.paths[]`로 경로 규칙을 정의합니다.

</details>

<details>
<summary>힌트 2</summary>

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
spec:
  rules:
  - host: app.example.com
    http:
      paths:
      - path: /app1
        pathType: Prefix
        backend:
          service:
            name: app1-svc
            port:
              number: 80
```

</details>

<details>
<summary>힌트 3</summary>

pathType은 `Prefix`, `Exact`, `ImplementationSpecific` 중 하나를 사용합니다. CKA에서는 주로 `Prefix`를 사용합니다.

</details>
