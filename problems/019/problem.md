# Problem 019: Service 연결 불가 트러블슈팅

| 항목 | 값 |
|------|-----|
| 문제 번호 | 019 |
| 도메인 | Troubleshooting |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 8분 |
| 네임스페이스 | cka-q019 |

## Context

네임스페이스 `cka-q019`에 `web-app` Deployment와 `web-svc` Service가 배포되어 있습니다. 그러나 Service를 통해 Pod에 접근할 수 없습니다. Service의 selector가 Deployment의 Pod 라벨과 일치하지 않아 Endpoints가 생성되지 않고 있습니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. `web-svc` Service의 Endpoints를 확인하세요. (비어 있을 것입니다)

2. `web-app` Deployment의 Pod 라벨과 `web-svc` Service의 selector를 비교하세요.

3. Service의 selector를 Deployment의 Pod 라벨과 일치하도록 수정하세요.
   - Deployment Pod 라벨: `app=web`
   - Service selector (현재 잘못된 값): `app=webapp`

4. 수정 후 Service에 Endpoints가 생성되었는지 확인하세요.

## Expected Outcome

- `kubectl -n cka-q019 get endpoints web-svc` 실행 시 IP 주소가 표시됨
- Service를 통해 Pod에 접근 가능

<details>
<summary>힌트 1</summary>

```bash
kubectl -n cka-q019 get endpoints web-svc
kubectl -n cka-q019 describe svc web-svc
kubectl -n cka-q019 get pods --show-labels
```

</details>

<details>
<summary>힌트 2</summary>

Service의 selector가 `app: webapp`이지만, Pod의 라벨은 `app: web`입니다. selector를 수정해야 합니다.

</details>

<details>
<summary>힌트 3</summary>

```bash
kubectl -n cka-q019 patch svc web-svc -p '{"spec":{"selector":{"app":"web"}}}'
```

또는:
```bash
kubectl -n cka-q019 edit svc web-svc
# selector.app: webapp → selector.app: web 으로 수정
```

</details>
