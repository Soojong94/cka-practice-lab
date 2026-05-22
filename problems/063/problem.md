# Problem 063: Helm 차트 커스터마이징

| 항목 | 값 |
|------|-----|
| 문제 번호 | 063 |
| 도메인 | Cluster Architecture, Installation & Configuration |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 8분 |
| 네임스페이스 | cka-q063 |

## Context

네임스페이스 `cka-q063`에 Helm 릴리스 `custom-app`이 기본 값으로 설치되어 있습니다. 이 릴리스를 커스터마이징하여 서비스 타입을 변경하고 커스텀 레이블을 추가해야 합니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. 릴리스 `custom-app`을 업그레이드하여 Service 타입을 `NodePort`로 변경하세요.

2. 같은 업그레이드에서 `commonLabels`에 `team=platform`을 추가하세요.

3. 업그레이드 후 Service의 타입이 `NodePort`인지 확인하세요.

4. Deployment에 `team=platform` 레이블이 추가되었는지 확인하세요.

## Expected Outcome

- Service 타입이 `NodePort`
- Deployment에 `team: platform` 레이블 존재
- 릴리스 revision이 2 이상

<details>
<summary>힌트 1</summary>

Helm upgrade에서 여러 값을 동시에 설정:
```bash
helm upgrade custom-app bitnami/nginx -n cka-q063 \
  --set service.type=NodePort \
  --set commonLabels.team=platform
```

</details>

<details>
<summary>힌트 2</summary>

현재 릴리스의 values 확인:
```bash
helm get values custom-app -n cka-q063
```

</details>

<details>
<summary>힌트 3</summary>

Service 타입 확인:
```bash
kubectl -n cka-q063 get svc -l app.kubernetes.io/instance=custom-app -o jsonpath='{.items[0].spec.type}'
```

</details>
