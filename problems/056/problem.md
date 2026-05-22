# Problem 056: kubeconfig context 조작

| 항목 | 값 |
|------|-----|
| 문제 번호 | 056 |
| 도메인 | Cluster Architecture, Installation & Configuration |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 8분 |
| 네임스페이스 | cka-q056 |

## Context

`/tmp/cka-q056/kubeconfig` 파일에 여러 context가 정의된 kubeconfig가 준비되어 있습니다. 이 파일을 분석하여 필요한 정보를 추출해야 합니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. `/tmp/cka-q056/kubeconfig` 파일에서 모든 context 이름을 추출하여 쉼표로 구분된 문자열로 네임스페이스 `cka-q056`에 ConfigMap `context-info`의 `contexts` 키에 저장하세요. (알파벳 순서로 정렬)

2. 현재 설정된 current-context 이름을 같은 ConfigMap `context-info`의 `current-context` 키에 저장하세요.

3. `dev-user`의 client-certificate-data를 base64 디코딩하여 인증서의 Subject(CN)를 추출하고, ConfigMap `context-info`의 `cert-subject` 키에 저장하세요.

4. 해당 kubeconfig에 정의된 클러스터 수를 ConfigMap `context-info`의 `cluster-count` 키에 저장하세요.

## Expected Outcome

- ConfigMap `context-info`가 네임스페이스 `cka-q056`에 존재
- `contexts` 키: `dev-context,prod-context,staging-context`
- `current-context` 키: `dev-context`
- `cert-subject` 키에 `CN=dev-user` 포함
- `cluster-count` 키: `3`

<details>
<summary>힌트 1</summary>

`kubectl config` 명령에 `--kubeconfig` 플래그를 사용하여 특정 kubeconfig 파일을 지정할 수 있습니다.

```bash
kubectl --kubeconfig=/tmp/cka-q056/kubeconfig config get-contexts -o name
```

</details>

<details>
<summary>힌트 2</summary>

인증서 디코딩은 다음과 같이 할 수 있습니다:

```bash
kubectl --kubeconfig=/tmp/cka-q056/kubeconfig config view --raw -o jsonpath='{.users[?(@.name=="dev-user")].user.client-certificate-data}' | base64 -d | openssl x509 -noout -subject
```

</details>

<details>
<summary>힌트 3</summary>

ConfigMap을 생성할 때 여러 키를 한번에 지정할 수 있습니다:

```bash
kubectl -n cka-q056 create configmap context-info \
  --from-literal=contexts="..." \
  --from-literal=current-context="..." \
  --from-literal=cert-subject="..." \
  --from-literal=cluster-count="..."
```

</details>
