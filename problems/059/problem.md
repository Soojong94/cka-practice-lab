# Problem 059: ServiceAccount 생성 및 Pod 연결

| 항목 | 값 |
|------|-----|
| 문제 번호 | 059 |
| 도메인 | Cluster Architecture, Installation & Configuration |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 7분 |
| 네임스페이스 | cka-q059 |

## Context

네임스페이스 `cka-q059`가 비어있는 상태입니다. 애플리케이션에서 사용할 전용 ServiceAccount를 생성하고, Pod에 연결하여 토큰이 올바르게 마운트되는지 확인해야 합니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. 네임스페이스 `cka-q059`에 ServiceAccount `app-sa`를 생성하세요.

2. 다음 스펙으로 Pod를 생성하세요:
   - 이름: `app-pod`
   - 이미지: `nginx:alpine`
   - ServiceAccount: `app-sa`
   - 네임스페이스: `cka-q059`

3. Pod가 Running 상태가 된 후, 토큰이 `/var/run/secrets/kubernetes.io/serviceaccount/token` 경로에 마운트되어 있는지 확인하세요.

4. Pod 내부에서 마운트된 토큰 파일의 존재 여부를 확인하고, 결과(`exists` 또는 `not-found`)를 ConfigMap `sa-verify`의 `token-status` 키에 저장하세요.

## Expected Outcome

- ServiceAccount `app-sa` 존재
- Pod `app-pod`가 ServiceAccount `app-sa`를 사용
- 토큰이 올바른 경로에 마운트됨
- ConfigMap `sa-verify`의 `token-status` = `exists`

<details>
<summary>힌트 1</summary>

ServiceAccount 생성:
```bash
kubectl -n cka-q059 create serviceaccount app-sa
```

</details>

<details>
<summary>힌트 2</summary>

Pod에 ServiceAccount를 지정하려면 `spec.serviceAccountName` 필드를 사용합니다:
```yaml
spec:
  serviceAccountName: app-sa
  containers:
  - name: nginx
    image: nginx:alpine
```

</details>

<details>
<summary>힌트 3</summary>

토큰 확인:
```bash
kubectl -n cka-q059 exec app-pod -- ls /var/run/secrets/kubernetes.io/serviceaccount/token
```

</details>
