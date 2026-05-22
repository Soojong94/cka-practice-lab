# Problem 100: NetworkPolicy + Service 통합 시나리오

| 항목 | 값 |
|------|-----|
| 문제 번호 | 100 |
| 도메인 | Services & Networking |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 15분 |
| 네임스페이스 | cka-q100 |

## Context

마이크로서비스 아키텍처에서 3개의 네임스페이스(`cka-q100-frontend`, `cka-q100-backend`, `cka-q100-db`)가 있습니다. 각 네임스페이스에 Pod와 Service가 동작 중입니다. Zero-trust 보안 모델에 따라 크로스 네임스페이스 NetworkPolicy를 구성해야 합니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. `cka-q100-backend` 네임스페이스에 NetworkPolicy `allow-from-frontend`를 생성하세요:
   - backend Pod (role: backend)로의 ingress 허용
   - 소스: `cka-q100-frontend` 네임스페이스의 Pod (namespaceSelector 사용)
   - 포트: TCP 8080

2. `cka-q100-db` 네임스페이스에 NetworkPolicy `allow-from-backend`를 생성하세요:
   - db Pod (role: db)로의 ingress 허용
   - 소스: `cka-q100-backend` 네임스페이스의 Pod (namespaceSelector 사용)
   - 포트: TCP 5432

3. `cka-q100-db` 네임스페이스에 NetworkPolicy `default-deny-ingress`를 생성하세요:
   - 모든 Pod에 적용 (빈 podSelector)
   - 모든 ingress 차단 (기본 거부)

4. 각 NetworkPolicy가 올바르게 구성되었는지 확인하세요.

## Expected Outcome

- `allow-from-frontend`: backend←frontend(ns), port 8080
- `allow-from-backend`: db←backend(ns), port 5432
- `default-deny-ingress`: db 네임스페이스 기본 ingress 거부
- 크로스 네임스페이스 규칙이 namespaceSelector로 올바르게 설정됨

<details>
<summary>힌트 1</summary>

크로스 네임스페이스 NetworkPolicy에서는 `namespaceSelector`를 사용합니다. 네임스페이스에는 자동으로 `kubernetes.io/metadata.name` 레이블이 부여됩니다.

</details>

<details>
<summary>힌트 2</summary>

```yaml
ingress:
- from:
  - namespaceSelector:
      matchLabels:
        kubernetes.io/metadata.name: cka-q100-frontend
  ports:
  - protocol: TCP
    port: 8080
```

</details>

<details>
<summary>힌트 3</summary>

기본 거부 정책과 허용 정책이 같은 네임스페이스에 있으면, 허용 정책의 규칙이 추가로 적용됩니다 (OR 연산). 따라서 default-deny + allow-from-backend를 함께 사용하면 backend에서만 접근 가능합니다.

</details>
