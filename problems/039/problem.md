# Problem 039: ServiceAccount 토큰 마운트 문제

| 항목 | 값 |
|------|-----|
| 문제 번호 | 039 |
| 도메인 | Troubleshooting |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 7분 |
| 네임스페이스 | cka-q039 |

## Context

네임스페이스 `cka-q039`에 `api-pod`이 ServiceAccount `api-sa`를 사용하여 동작 중입니다. 이 Pod는 Kubernetes API를 호출해야 하지만, ServiceAccount 토큰이 마운트되지 않아 인증에 실패합니다.

원인은 ServiceAccount `api-sa`에 `automountServiceAccountToken: false`가 설정되어 있기 때문입니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. Pod `api-pod`에서 토큰 파일이 존재하는지 확인하세요:
   - `/var/run/secrets/kubernetes.io/serviceaccount/token`

2. ServiceAccount `api-sa`의 `automountServiceAccountToken` 설정을 확인하세요.

3. Pod를 삭제하고, Pod spec에 `automountServiceAccountToken: true`를 명시적으로 설정하여 재생성하세요.
   - Pod spec의 설정이 ServiceAccount 설정보다 우선합니다.

4. 새 Pod에서 토큰 파일이 마운트되었는지 확인하세요.

## Expected Outcome

- Pod `api-pod`이 `Running` 상태
- `/var/run/secrets/kubernetes.io/serviceaccount/token` 파일이 Pod 내부에 존재
- Pod spec에 `automountServiceAccountToken: true` 설정됨

<details>
<summary>힌트 1</summary>

```bash
kubectl -n cka-q039 exec api-pod -- ls /var/run/secrets/kubernetes.io/serviceaccount/
# 토큰 파일이 없으면 마운트되지 않은 것
```

</details>

<details>
<summary>힌트 2</summary>

ServiceAccount의 `automountServiceAccountToken: false`는 Pod spec에서 `automountServiceAccountToken: true`로 오버라이드할 수 있습니다.

</details>

<details>
<summary>힌트 3</summary>

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: api-pod
spec:
  serviceAccountName: api-sa
  automountServiceAccountToken: true
  containers:
  - name: kubectl
    image: bitnami/kubectl:latest
    command: ["sleep", "3600"]
```

</details>
