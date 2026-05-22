# Problem 079: API Server 감사 로깅

| 항목 | 값 |
|------|-----|
| 문제 번호 | 079 |
| 도메인 | Cluster Architecture, Installation & Configuration |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 9분 |
| 네임스페이스 | cka-q079 |

## Context

네임스페이스 `cka-q079`에 불완전한 감사 정책(Audit Policy) 템플릿이 담긴 ConfigMap `audit-policy`가 있습니다. 보안팀의 요구사항에 맞게 감사 정책을 완성하세요.

> 참고: https://kubernetes.io/docs/tasks/debug/debug-cluster/audit/

## Tasks

1. ConfigMap `audit-policy`의 `policy.yaml`에서 첫 번째 규칙을 완성하세요:
   - Secrets에 대한 모든 요청을 `RequestResponse` 레벨로 기록
   - resources: `secrets`, apiGroups: `""`

2. 두 번째 규칙을 완성하세요:
   - Namespace 변경(create, update, delete)을 `Metadata` 레벨로 기록
   - resources: `namespaces`, apiGroups: `""`
   - verbs: `create`, `update`, `delete`

3. 세 번째 규칙을 완성하세요:
   - ConfigMap 읽기 요청(get, list, watch)을 무시 (`None` 레벨)
   - resources: `configmaps`, apiGroups: `""`
   - verbs: `get`, `list`, `watch`

4. 수정된 ConfigMap을 클러스터에 적용하세요.

## Expected Outcome

- 규칙 1: Secrets → RequestResponse 레벨
- 규칙 2: Namespaces (create/update/delete) → Metadata 레벨
- 규칙 3: ConfigMaps (get/list/watch) → None 레벨

<details>
<summary>힌트 1</summary>

감사 정책 레벨:
- `None`: 로깅하지 않음
- `Metadata`: 요청 메타데이터만 기록 (사용자, 타임스탬프, 리소스 등)
- `Request`: 메타데이터 + 요청 본문
- `RequestResponse`: 메타데이터 + 요청 본문 + 응답 본문

</details>

<details>
<summary>힌트 2</summary>

감사 정책 규칙 형식:
```yaml
rules:
- level: RequestResponse
  resources:
  - group: ""
    resources: ["secrets"]
```

</details>

<details>
<summary>힌트 3</summary>

특정 동작만 필터링하려면 `verbs` 필드를 사용합니다:
```yaml
- level: Metadata
  resources:
  - group: ""
    resources: ["namespaces"]
  verbs: ["create", "update", "delete"]
```

</details>
