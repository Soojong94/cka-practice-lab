# Problem 069: API 리소스 탐색

| 항목 | 값 |
|------|-----|
| 문제 번호 | 069 |
| 도메인 | Cluster Architecture, Installation & Configuration |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 7분 |
| 네임스페이스 | cka-q069 |

## Context

Kubernetes API에는 다양한 리소스 타입이 존재합니다. `kubectl api-resources` 명령을 사용하여 API 리소스를 탐색하고 정보를 추출해야 합니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. 네임스페이스에 속하는(namespaced) 모든 리소스 타입의 수를 세어 ConfigMap `api-info`의 `namespaced-count` 키에 저장하세요.

2. `deployments` 리소스가 속하는 API 그룹을 ConfigMap `api-info`의 `deployments-apigroup` 키에 저장하세요.

3. `cronjobs` 리소스가 네임스페이스에 속하는지(namespaced) 여부를 ConfigMap `api-info`의 `cronjobs-namespaced` 키에 `true` 또는 `false`로 저장하세요.

4. `nodes` 리소스가 네임스페이스에 속하는지 여부를 ConfigMap `api-info`의 `nodes-namespaced` 키에 `true` 또는 `false`로 저장하세요.

## Expected Outcome

- ConfigMap `api-info`가 네임스페이스 `cka-q069`에 존재
- `namespaced-count`: 실제 namespaced 리소스 수 (숫자)
- `deployments-apigroup`: `apps`
- `cronjobs-namespaced`: `true`
- `nodes-namespaced`: `false`

<details>
<summary>힌트 1</summary>

namespaced 리소스 목록:
```bash
kubectl api-resources --namespaced=true
kubectl api-resources --namespaced=true --no-headers | wc -l
```

</details>

<details>
<summary>힌트 2</summary>

특정 리소스의 API 그룹 확인:
```bash
kubectl api-resources | grep deployments
# deployments   deploy   apps/v1   true   Deployment
```

</details>

<details>
<summary>힌트 3</summary>

리소스의 namespaced 여부 확인:
```bash
kubectl api-resources | grep -w cronjobs
# NAMESPACED 컬럼이 true/false
```

</details>
