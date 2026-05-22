# Problem 098: Service Traffic Policy

| 항목 | 값 |
|------|-----|
| 문제 번호 | 098 |
| 도메인 | Services & Networking |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 8분 |
| 네임스페이스 | cka-q098 |

## Context

네임스페이스 `cka-q098`에 `web-app` Deployment(2 replicas)와 Service가 동작 중입니다. 트래픽 정책을 설정하여 로컬 노드의 Pod로만 트래픽을 라우팅하도록 구성해야 합니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. Service `web-internal`을 생성하세요:
   - 타입: `ClusterIP`
   - selector: `app: web-app`
   - port: 80
   - `internalTrafficPolicy: Local`

2. Service `web-external`을 생성하세요:
   - 타입: `NodePort`
   - selector: `app: web-app`
   - port: 80
   - `externalTrafficPolicy: Local`

3. 두 Service의 Traffic Policy가 올바르게 설정되었는지 확인하세요.

## Expected Outcome

- Service `web-internal`의 internalTrafficPolicy=Local
- Service `web-external`의 externalTrafficPolicy=Local
- 두 Service 모두 정상 동작

<details>
<summary>힌트 1</summary>

`internalTrafficPolicy: Local`은 클러스터 내부 트래픽을 같은 노드의 Pod로만 라우팅합니다. `externalTrafficPolicy: Local`은 외부 트래픽을 같은 노드의 Pod로만 라우팅합니다.

</details>

<details>
<summary>힌트 2</summary>

```yaml
spec:
  internalTrafficPolicy: Local
```
또는
```yaml
spec:
  externalTrafficPolicy: Local
```

</details>

<details>
<summary>힌트 3</summary>

`externalTrafficPolicy`는 NodePort 또는 LoadBalancer 타입 Service에서만 사용 가능합니다. ClusterIP Service에서는 `internalTrafficPolicy`를 사용합니다.

</details>
