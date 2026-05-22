# Problem 071: Admission Controller 이해

| 항목 | 값 |
|------|-----|
| 문제 번호 | 071 |
| 도메인 | Cluster Architecture, Installation & Configuration |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 7분 |
| 네임스페이스 | cka-q071 |

## Context

네임스페이스 `cka-q071`에 `webhook-config`라는 ConfigMap이 있습니다. 이 ConfigMap에는 불완전한 `ValidatingWebhookConfiguration` YAML 템플릿이 저장되어 있습니다.

보안팀에서 Pod 생성 시 유효성 검사를 수행하는 Admission Webhook을 구성하려 합니다. 템플릿의 플레이스홀더를 올바른 값으로 교체하세요.

> 참고: https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/

## Tasks

1. ConfigMap `webhook-config`의 `webhook.yaml` 내용에서 `rules` 섹션의 `operations`를 Pod **생성(CREATE)** 요청을 가로채도록 설정하세요.

2. `rules` 섹션의 `resources`를 `pods`로 설정하세요.

3. `failurePolicy`를 `Ignore`로 설정하세요 (웹훅 서버 장애 시 요청을 허용).

4. `sideEffects`를 `None`으로 설정하세요 (웹훅이 부작용 없음을 선언).

5. 수정된 ConfigMap을 클러스터에 적용하세요.

## Expected Outcome

- ConfigMap `webhook-config`의 `webhook.yaml`에서:
  - `operations: ["CREATE"]`
  - `resources: ["pods"]`
  - `failurePolicy: Ignore`
  - `sideEffects: None`

<details>
<summary>힌트 1</summary>

ConfigMap을 수정하려면 `kubectl -n cka-q071 edit configmap webhook-config` 또는 YAML 파일을 작성하여 `kubectl apply`로 적용할 수 있습니다.

</details>

<details>
<summary>힌트 2</summary>

ValidatingWebhookConfiguration의 주요 필드:
- `failurePolicy`: `Fail` 또는 `Ignore` (웹훅 서버 장애 시 동작)
- `sideEffects`: `None`, `NoneOnDryRun`, `Unknown` (부작용 여부)
- `rules.operations`: `CREATE`, `UPDATE`, `DELETE`, `CONNECT` 중 선택

</details>

<details>
<summary>힌트 3</summary>

```bash
kubectl -n cka-q071 get configmap webhook-config -o yaml
# webhook.yaml 내용을 확인하고 플레이스홀더를 교체
```

</details>
