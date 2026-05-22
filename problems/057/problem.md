# Problem 057: RBAC Role/RoleBinding 생성

| 항목 | 값 |
|------|-----|
| 문제 번호 | 057 |
| 도메인 | Cluster Architecture, Installation & Configuration |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 7분 |
| 네임스페이스 | cka-q057 |

## Context

네임스페이스 `cka-q057`에 ServiceAccount `developer`가 생성되어 있습니다. 개발팀에서 이 ServiceAccount에 Pod와 ConfigMap에 대한 읽기 권한을 부여해달라고 요청했습니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. 네임스페이스 `cka-q057`에 다음 스펙으로 Role을 생성하세요:
   - 이름: `developer-role`
   - 리소스: `pods`, `configmaps`
   - 동작(verbs): `get`, `list`, `watch`

2. 네임스페이스 `cka-q057`에 다음 스펙으로 RoleBinding을 생성하세요:
   - 이름: `developer-binding`
   - Role 참조: `developer-role`
   - Subject: ServiceAccount `developer` (네임스페이스 `cka-q057`)

3. `kubectl auth can-i` 명령으로 ServiceAccount `developer`가 pods를 list할 수 있는지 확인하고, 결과를 ConfigMap `rbac-verify`의 `can-list-pods` 키에 저장하세요.

4. 같은 방법으로 ServiceAccount `developer`가 pods를 delete할 수 없는지 확인하고, 결과를 ConfigMap `rbac-verify`의 `can-delete-pods` 키에 저장하세요.

## Expected Outcome

- Role `developer-role`이 올바른 rules로 존재
- RoleBinding `developer-binding`이 올바르게 바인딩됨
- ConfigMap `rbac-verify`의 `can-list-pods` = `yes`
- ConfigMap `rbac-verify`의 `can-delete-pods` = `no`

<details>
<summary>힌트 1</summary>

Role 생성:
```bash
kubectl -n cka-q057 create role developer-role --verb=get,list,watch --resource=pods,configmaps
```

</details>

<details>
<summary>힌트 2</summary>

RoleBinding 생성:
```bash
kubectl -n cka-q057 create rolebinding developer-binding --role=developer-role --serviceaccount=cka-q057:developer
```

</details>

<details>
<summary>힌트 3</summary>

auth can-i 확인:
```bash
kubectl -n cka-q057 auth can-i list pods --as=system:serviceaccount:cka-q057:developer
```

</details>
