# Problem 087: NetworkPolicy 기본 거부 정책

| 항목 | 값 |
|------|-----|
| 문제 번호 | 087 |
| 도메인 | Services & Networking |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 12분 |
| 네임스페이스 | cka-q087 |

## Context

네임스페이스 `cka-q087`에 `web`, `api`, `db` Pod가 동작 중입니다. Zero-trust 보안 모델을 적용하여 기본적으로 모든 트래픽을 차단하고, 필요한 통신만 명시적으로 허용해야 합니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. 기본 거부 정책 `default-deny-all`을 생성하세요:
   - 모든 Pod에 적용 (빈 podSelector)
   - Ingress와 Egress 모두 차단

2. NetworkPolicy `allow-web-to-api`를 생성하세요:
   - `api` Pod (role: api)로의 ingress 허용
   - 소스: `web` Pod (role: web)
   - 포트: TCP 8080

3. NetworkPolicy `allow-api-to-db`를 생성하세요:
   - `db` Pod (role: db)로의 ingress 허용
   - 소스: `api` Pod (role: api)
   - 포트: TCP 5432

4. DNS 통신을 위한 egress 규칙도 포함하세요 (모든 Pod에서 kube-dns port 53 허용).

## Expected Outcome

- `default-deny-all` NetworkPolicy 존재 (빈 podSelector, Ingress+Egress)
- `allow-web-to-api` NetworkPolicy 존재 (api←web, port 8080)
- `allow-api-to-db` NetworkPolicy 존재 (db←api, port 5432)

<details>
<summary>힌트 1</summary>

기본 거부 정책은 빈 podSelector(`{}`)로 모든 Pod에 적용하고, policyTypes에 Ingress와 Egress를 모두 포함하되 규칙은 비워둡니다.

</details>

<details>
<summary>힌트 2</summary>

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

</details>

<details>
<summary>힌트 3</summary>

허용 정책은 별도의 NetworkPolicy로 생성합니다. 같은 Pod에 여러 NetworkPolicy가 적용되면 규칙이 합산(OR)됩니다.

</details>
