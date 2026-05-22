# Problem 020: NetworkPolicy로 인한 통신 차단 해결

| 항목 | 값 |
|------|-----|
| 문제 번호 | 020 |
| 도메인 | Troubleshooting |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 10분 |
| 네임스페이스 | cka-q020 |

## Context

네임스페이스 `cka-q020`에 `client` Pod와 `server` Pod가 배포되어 있습니다. `server` Pod는 nginx를 실행하며 포트 80에서 서비스합니다. 그러나 NetworkPolicy `deny-all-ingress`가 적용되어 `server` Pod로의 모든 인바운드 트래픽이 차단되고 있습니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. 현재 적용된 NetworkPolicy를 확인하세요.

2. `client` Pod에서 `server` Pod로 포트 80 접근이 차단되는 것을 확인하세요.

3. NetworkPolicy `deny-all-ingress`를 수정하여 `client` Pod(라벨: `role=client`)에서 `server` Pod로 포트 80 TCP 트래픽을 허용하세요.

4. 수정 후 `client` Pod에서 `server` Pod로 접근이 가능한지 확인하세요.

## Expected Outcome

- NetworkPolicy가 `client` Pod에서 `server` Pod 포트 80으로의 트래픽을 허용
- `client` Pod에서 `server` Pod로 curl 접근 성공

<details>
<summary>힌트 1</summary>

```bash
kubectl -n cka-q020 get networkpolicy
kubectl -n cka-q020 describe networkpolicy deny-all-ingress
```

</details>

<details>
<summary>힌트 2</summary>

NetworkPolicy에 ingress 규칙을 추가하여 특정 Pod에서의 트래픽을 허용할 수 있습니다:
```yaml
ingress:
- from:
  - podSelector:
      matchLabels:
        role: client
  ports:
  - protocol: TCP
    port: 80
```

</details>

<details>
<summary>힌트 3</summary>

```bash
kubectl -n cka-q020 apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-ingress
spec:
  podSelector:
    matchLabels:
      role: server
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: client
    ports:
    - protocol: TCP
      port: 80
EOF
```

</details>
