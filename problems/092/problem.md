# Problem 092: Ingress TLS 설정

| 항목 | 값 |
|------|-----|
| 문제 번호 | 092 |
| 도메인 | Services & Networking |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 10분 |
| 네임스페이스 | cka-q092 |

## Context

네임스페이스 `cka-q092`에 `secure-app` Deployment와 `secure-app-svc` Service가 동작 중입니다. ConfigMap `tls-files`에 TLS 인증서(tls.crt)와 키(tls.key)가 저장되어 있습니다. HTTPS 접근을 위한 Ingress TLS 설정을 구성해야 합니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. ConfigMap `tls-files`에서 인증서와 키를 추출하여 TLS Secret을 생성하세요:
   - Secret 이름: `secure-tls`
   - 타입: `kubernetes.io/tls`
   - tls.crt와 tls.key 포함

2. Ingress `secure-ingress`를 생성하세요:
   - host: `secure.example.com`
   - TLS 설정: secretName `secure-tls`, host `secure.example.com`
   - 경로: `/` → `secure-app-svc` port 80, pathType `Prefix`

3. Ingress의 TLS 설정이 올바른지 확인하세요.

## Expected Outcome

- Secret `secure-tls` (type: kubernetes.io/tls) 존재
- Ingress `secure-ingress`에 TLS 섹션 존재
- TLS host가 `secure.example.com`, secretName이 `secure-tls`

<details>
<summary>힌트 1</summary>

ConfigMap에서 인증서 추출:
```bash
kubectl -n cka-q092 get configmap tls-files -o jsonpath='{.data.tls\.crt}' > /tmp/tls.crt
kubectl -n cka-q092 get configmap tls-files -o jsonpath='{.data.tls\.key}' > /tmp/tls.key
```

</details>

<details>
<summary>힌트 2</summary>

TLS Secret 생성:
```bash
kubectl -n cka-q092 create secret tls secure-tls --cert=/tmp/tls.crt --key=/tmp/tls.key
```

</details>

<details>
<summary>힌트 3</summary>

Ingress TLS 설정:
```yaml
spec:
  tls:
  - hosts:
    - secure.example.com
    secretName: secure-tls
```

</details>
