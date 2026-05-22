# Problem 070: kubeconfig 인증서 디코딩

| 항목 | 값 |
|------|-----|
| 문제 번호 | 070 |
| 도메인 | Cluster Architecture, Installation & Configuration |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 8분 |
| 네임스페이스 | cka-q070 |

## Context

`/tmp/cka-q070/kubeconfig` 파일에 base64로 인코딩된 클라이언트 인증서가 포함되어 있습니다. 이 인증서를 디코딩하여 발급자(Issuer)와 만료일(Expiration) 정보를 추출해야 합니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. `/tmp/cka-q070/kubeconfig` 파일에서 `admin-user`의 `client-certificate-data`를 추출하세요.

2. 추출한 데이터를 base64 디코딩하여 인증서의 Issuer(발급자)를 확인하고, ConfigMap `cert-info`의 `issuer` 키에 저장하세요.

3. 같은 인증서의 만료일(Not After)을 확인하고, ConfigMap `cert-info`의 `expiry` 키에 저장하세요.

4. 인증서의 Subject(주체)를 확인하고, ConfigMap `cert-info`의 `subject` 키에 저장하세요.

5. 인증서가 현재 유효한지(만료되지 않았는지) 확인하고, ConfigMap `cert-info`의 `is-valid` 키에 `true` 또는 `false`를 저장하세요.

## Expected Outcome

- ConfigMap `cert-info`가 네임스페이스 `cka-q070`에 존재
- `issuer` 키에 인증서 발급자 정보 포함 (CN=kubernetes-ca 포함)
- `expiry` 키에 만료일 포함
- `subject` 키에 CN=admin-user 포함
- `is-valid` 키: `true`

<details>
<summary>힌트 1</summary>

kubeconfig에서 인증서 데이터 추출:
```bash
kubectl --kubeconfig=/tmp/cka-q070/kubeconfig config view --raw \
  -o jsonpath='{.users[?(@.name=="admin-user")].user.client-certificate-data}'
```

</details>

<details>
<summary>힌트 2</summary>

인증서 디코딩 및 정보 확인:
```bash
kubectl --kubeconfig=/tmp/cka-q070/kubeconfig config view --raw \
  -o jsonpath='{.users[?(@.name=="admin-user")].user.client-certificate-data}' | \
  base64 -d | openssl x509 -noout -issuer -enddate -subject
```

</details>

<details>
<summary>힌트 3</summary>

인증서 유효성 확인:
```bash
kubectl --kubeconfig=/tmp/cka-q070/kubeconfig config view --raw \
  -o jsonpath='{.users[?(@.name=="admin-user")].user.client-certificate-data}' | \
  base64 -d | openssl x509 -noout -checkend 0
# 반환값 0이면 유효, 1이면 만료
```

</details>
