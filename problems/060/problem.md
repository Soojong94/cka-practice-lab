# Problem 060: Pod에서 K8s API 호출

| 항목 | 값 |
|------|-----|
| 문제 번호 | 060 |
| 도메인 | Cluster Architecture, Installation & Configuration |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 10분 |
| 네임스페이스 | cka-q060 |

## Context

네임스페이스 `cka-q060`에 ServiceAccount `api-reader`가 생성되어 있으며, 이 SA에는 secrets를 list/get할 수 있는 Role이 바인딩되어 있습니다. Pod 내부에서 Kubernetes API를 직접 호출하여 secrets 목록을 가져와야 합니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. 다음 스펙으로 Pod를 생성하세요:
   - 이름: `api-pod`
   - 이미지: `curlimages/curl:latest`
   - ServiceAccount: `api-reader`
   - command: `["sleep", "3600"]`
   - 네임스페이스: `cka-q060`

2. Pod가 Running 상태가 된 후, Pod 내부에서 마운트된 ServiceAccount 토큰을 사용하여 Kubernetes API를 호출하세요. API 엔드포인트: `https://kubernetes.default.svc/api/v1/namespaces/cka-q060/secrets`

3. API 호출 결과에서 secret 이름 목록을 추출하여 ConfigMap `api-result`의 `secret-names` 키에 저장하세요. (쉼표로 구분)

4. API 호출 시 사용한 HTTP 응답 코드를 ConfigMap `api-result`의 `response-code` 키에 저장하세요.

## Expected Outcome

- Pod `api-pod`가 Running 상태이며 ServiceAccount `api-reader` 사용
- ConfigMap `api-result`의 `secret-names` 키에 secret 이름 포함
- ConfigMap `api-result`의 `response-code` = `200`

<details>
<summary>힌트 1</summary>

Pod 내부에서 토큰과 CA 인증서 경로:
```bash
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
```

</details>

<details>
<summary>힌트 2</summary>

curl로 API 호출:
```bash
curl -s --cacert $CACERT -H "Authorization: Bearer $TOKEN" \
  https://kubernetes.default.svc/api/v1/namespaces/cka-q060/secrets
```

</details>

<details>
<summary>힌트 3</summary>

응답 코드만 확인:
```bash
curl -s -o /dev/null -w "%{http_code}" --cacert $CACERT -H "Authorization: Bearer $TOKEN" \
  https://kubernetes.default.svc/api/v1/namespaces/cka-q060/secrets
```

</details>
