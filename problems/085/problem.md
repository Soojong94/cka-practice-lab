# Problem 085: NetworkPolicy Ingress 규칙

| 항목 | 값 |
|------|-----|
| 문제 번호 | 085 |
| 도메인 | Services & Networking |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 8분 |
| 네임스페이스 | cka-q085 |

## Context

네임스페이스 `cka-q085`에 `frontend`, `backend`, `other` Pod가 동작 중입니다. `backend` Pod는 nginx를 실행하며 port 80에서 수신합니다. 보안 요구사항에 따라 `backend`로의 접근을 `frontend` Pod에서만 허용해야 합니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. 네임스페이스 `cka-q085`에 다음 스펙으로 NetworkPolicy를 생성하세요:
   - 이름: `allow-frontend`
   - 적용 대상: label `role: backend`인 Pod
   - Ingress 규칙: label `role: frontend`인 Pod에서 port 80으로의 접근만 허용

2. NetworkPolicy가 올바르게 적용되었는지 확인하세요:
   - `frontend` Pod에서 `backend` Pod로 curl 가능
   - `other` Pod에서 `backend` Pod로 curl 불가

3. NetworkPolicy의 podSelector와 ingress from 규칙이 올바른지 확인하세요.

## Expected Outcome

- `kubectl -n cka-q085 get networkpolicy allow-frontend` 존재
- NetworkPolicy의 podSelector가 `role: backend`
- ingress from에 `role: frontend` podSelector와 port 80 규칙 존재

<details>
<summary>힌트 1</summary>

NetworkPolicy의 `spec.podSelector`는 정책이 적용될 대상 Pod를 선택합니다. `spec.ingress[].from[].podSelector`는 허용할 소스 Pod를 선택합니다.

</details>

<details>
<summary>힌트 2</summary>

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend
spec:
  podSelector:
    matchLabels:
      role: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: frontend
    ports:
    - protocol: TCP
      port: 80
```

</details>

<details>
<summary>힌트 3</summary>

Docker Desktop은 기본적으로 NetworkPolicy를 강제하지 않지만, 리소스 자체는 생성 가능합니다. CKA 시험에서는 NetworkPolicy 리소스의 올바른 구성이 중요합니다.

</details>
