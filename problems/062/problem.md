# Problem 062: Helm 차트 설치 및 관리

| 항목 | 값 |
|------|-----|
| 문제 번호 | 062 |
| 도메인 | Cluster Architecture, Installation & Configuration |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 10분 |
| 네임스페이스 | cka-q062 |

## Context

Helm이 설치되어 있으며, bitnami 리포지토리가 추가되어 있습니다. 네임스페이스 `cka-q062`에 nginx 차트를 설치하고 관리해야 합니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. bitnami 리포지토리에서 nginx 차트를 네임스페이스 `cka-q062`에 릴리스 이름 `web-release`로 설치하세요. (기본 값 사용)

2. 설치된 릴리스가 정상적으로 배포되었는지 확인하세요. (`helm list -n cka-q062`)

3. `web-release`를 업그레이드하여 `replicaCount=2`로 변경하세요.

4. 업그레이드 후 Deployment의 replicas가 2인지 확인하세요.

## Expected Outcome

- `helm list -n cka-q062`에서 `web-release` 릴리스 확인 가능
- Deployment의 replicas가 2
- 릴리스 revision이 2 이상

<details>
<summary>힌트 1</summary>

Helm 차트 설치:
```bash
helm install web-release bitnami/nginx -n cka-q062
```

</details>

<details>
<summary>힌트 2</summary>

Helm 업그레이드:
```bash
helm upgrade web-release bitnami/nginx -n cka-q062 --set replicaCount=2
```

</details>

<details>
<summary>힌트 3</summary>

릴리스 상태 확인:
```bash
helm list -n cka-q062
helm history web-release -n cka-q062
```

</details>
