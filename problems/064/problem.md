# Problem 064: CRD 생성 및 Custom Resource 관리

| 항목 | 값 |
|------|-----|
| 문제 번호 | 064 |
| 도메인 | Cluster Architecture, Installation & Configuration |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 10분 |
| 네임스페이스 | cka-q064 |

## Context

네임스페이스 `cka-q064`가 비어있는 상태입니다. 커스텀 리소스 정의(CRD)를 생성하고, 해당 타입의 Custom Resource를 생성해야 합니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. 다음 스펙으로 CustomResourceDefinition을 생성하세요:
   - 이름: `databases.stable.example.com`
   - Group: `stable.example.com`
   - Version: `v1`
   - Scope: `Namespaced`
   - Kind: `Database`
   - Plural: `databases`
   - Singular: `database`
   - spec 필드: `databaseName` (string), `version` (string), `replicas` (integer)

2. CRD가 정상적으로 등록되었는지 확인하세요.

3. 네임스페이스 `cka-q064`에 다음 스펙으로 Custom Resource를 생성하세요:
   - 이름: `my-postgres`
   - databaseName: `postgres`
   - version: `15.4`
   - replicas: `3`

4. 생성된 Custom Resource를 조회하여 spec 필드가 올바른지 확인하세요.

## Expected Outcome

- CRD `databases.stable.example.com` 존재
- Custom Resource `my-postgres`가 네임스페이스 `cka-q064`에 존재
- CR의 spec 필드가 올바르게 설정됨

<details>
<summary>힌트 1</summary>

CRD YAML 구조:
```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: databases.stable.example.com
spec:
  group: stable.example.com
  versions:
  - name: v1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            properties:
              databaseName:
                type: string
              version:
                type: string
              replicas:
                type: integer
  scope: Namespaced
  names:
    plural: databases
    singular: database
    kind: Database
```

</details>

<details>
<summary>힌트 2</summary>

Custom Resource 생성:
```yaml
apiVersion: stable.example.com/v1
kind: Database
metadata:
  name: my-postgres
  namespace: cka-q064
spec:
  databaseName: postgres
  version: "15.4"
  replicas: 3
```

</details>

<details>
<summary>힌트 3</summary>

CR 조회:
```bash
kubectl -n cka-q064 get databases
kubectl -n cka-q064 get database my-postgres -o yaml
```

</details>
