# Problem 033: Ingress 라우팅 오류 수정

| 항목 | 값 |
|------|-----|
| 문제 번호 | 033 |
| 도메인 | Troubleshooting |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 7분 |
| 네임스페이스 | cka-q033 |

## Context

네임스페이스 `cka-q033`에 `web-app` Deployment와 `web-svc` Service가 정상 동작 중입니다. 그러나 Ingress `web-ingress`의 설정 오류로 인해 외부에서 `/app` 경로로 접근할 때 라우팅이 올바르게 되지 않습니다.

Service `web-svc`는 포트 `80`에서 동작합니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. Ingress `web-ingress`의 현재 설정을 확인하고 문제점을 파악하세요.

2. `pathType`을 `Exact`에서 `Prefix`로 변경하세요.
   - `/app` 이하 모든 경로가 라우팅되어야 합니다.

3. backend service의 port를 올바른 값(`80`)으로 수정하세요.
   - 현재 잘못된 포트 `8080`이 설정되어 있습니다.

4. 수정된 Ingress 설정이 올바른지 확인하세요.

## Expected Outcome

- Ingress `web-ingress`의 pathType이 `Prefix`
- Ingress backend service port가 `80`
- `/app` 경로 이하 모든 요청이 `web-svc:80`으로 라우팅

<details>
<summary>힌트 1</summary>

`kubectl -n cka-q033 get ingress web-ingress -o yaml`로 현재 설정을 확인합니다.

</details>

<details>
<summary>힌트 2</summary>

pathType의 차이:
- `Exact`: 정확히 `/app`만 매칭
- `Prefix`: `/app`, `/app/`, `/app/sub` 등 모두 매칭

</details>

<details>
<summary>힌트 3</summary>

```bash
kubectl -n cka-q033 edit ingress web-ingress
```
또는:
```bash
kubectl -n cka-q033 patch ingress web-ingress --type='json' -p='[
  {"op": "replace", "path": "/spec/rules/0/http/paths/0/pathType", "value": "Prefix"},
  {"op": "replace", "path": "/spec/rules/0/http/paths/0/backend/service/port/number", "value": 80}
]'
```

</details>
