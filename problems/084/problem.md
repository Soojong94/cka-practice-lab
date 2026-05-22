# Problem 084: Headless Service 구성

| 항목 | 값 |
|------|-----|
| 문제 번호 | 084 |
| 도메인 | Services & Networking |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 8분 |
| 네임스페이스 | cka-q084 |

## Context

네임스페이스 `cka-q084`에 `db`라는 StatefulSet이 3개 레플리카로 동작 중입니다. StatefulSet의 각 Pod가 고유한 DNS 레코드를 가질 수 있도록 Headless Service를 구성해야 합니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. 네임스페이스 `cka-q084`에 다음 스펙으로 Headless Service를 생성하세요:
   - 이름: `db-headless`
   - clusterIP: `None`
   - selector: `app: db`
   - 포트: `5432` (targetPort: `5432`)

2. 각 StatefulSet Pod가 고유한 DNS 레코드를 가지는지 확인하세요:
   - `db-0.db-headless.cka-q084.svc.cluster.local`
   - `db-1.db-headless.cka-q084.svc.cluster.local`
   - `db-2.db-headless.cka-q084.svc.cluster.local`

3. 테스트 Pod에서 각 Pod의 DNS를 nslookup으로 확인하세요:
   - `kubectl -n cka-q084 run dns-check --image=busybox:1.36 --rm -it --restart=Never -- nslookup db-0.db-headless.cka-q084.svc.cluster.local`

## Expected Outcome

- `kubectl -n cka-q084 get svc db-headless` 실행 시 ClusterIP가 `None`
- 각 Pod의 개별 DNS 레코드가 해석 가능

<details>
<summary>힌트 1</summary>

Headless Service는 `spec.clusterIP: None`으로 설정합니다. StatefulSet의 `spec.serviceName`과 Service 이름이 일치해야 합니다.

</details>

<details>
<summary>힌트 2</summary>

StatefulSet Pod의 DNS 형식: `<pod-name>.<service-name>.<namespace>.svc.cluster.local`

</details>

<details>
<summary>힌트 3</summary>

```yaml
apiVersion: v1
kind: Service
metadata:
  name: db-headless
spec:
  clusterIP: None
  selector:
    app: db
  ports:
  - port: 5432
    targetPort: 5432
```

</details>
