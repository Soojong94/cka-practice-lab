# Problem 031: RBAC 권한 부족 디버깅

| 항목 | 값 |
|------|-----|
| 문제 번호 | 031 |
| 도메인 | Troubleshooting |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 8분 |
| 네임스페이스 | cka-q031 |

## Context

네임스페이스 `cka-q031`에 ServiceAccount `app-sa`를 사용하는 Pod `app-pod`이 동작 중입니다. 이 애플리케이션은 동일 네임스페이스의 Pod 목록을 조회하고, ConfigMap을 생성해야 합니다. 그러나 현재 RBAC 설정이 불완전하여 필요한 작업을 수행할 수 없습니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. `kubectl auth can-i` 명령으로 ServiceAccount `app-sa`가 현재 어떤 권한을 가지고 있는지 확인하세요.

2. Role `app-role`을 수정하여 다음 권한을 추가하세요:
   - `pods` 리소스에 대한 `list` verb
   - `configmaps` 리소스에 대한 `create` verb

3. 수정 후 `kubectl auth can-i`로 다음을 확인하세요:
   - `app-sa`가 pods를 list할 수 있는지
   - `app-sa`가 configmaps를 create할 수 있는지

4. 기존 RoleBinding `app-rolebinding`이 올바르게 연결되어 있는지 확인하세요.

## Expected Outcome

- `kubectl auth can-i list pods --as=system:serviceaccount:cka-q031:app-sa -n cka-q031` → `yes`
- `kubectl auth can-i create configmaps --as=system:serviceaccount:cka-q031:app-sa -n cka-q031` → `yes`
- `kubectl auth can-i get pods --as=system:serviceaccount:cka-q031:app-sa -n cka-q031` → `yes`

<details>
<summary>힌트 1</summary>

`kubectl auth can-i --list --as=system:serviceaccount:cka-q031:app-sa -n cka-q031`으로 현재 권한 전체를 확인할 수 있습니다.

</details>

<details>
<summary>힌트 2</summary>

Role에 여러 리소스에 대한 권한을 추가하려면 rules 배열에 항목을 추가합니다:

```yaml
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
- apiGroups: [""]
  resources: ["configmaps"]
  verbs: ["create"]
```

</details>

<details>
<summary>힌트 3</summary>

`kubectl -n cka-q031 edit role app-role`로 직접 수정하거나, `kubectl apply`로 전체 Role을 다시 적용할 수 있습니다.

</details>
