# Problem 093: Service ExternalName 구성

| 항목 | 값 |
|------|-----|
| 문제 번호 | 093 |
| 도메인 | Services & Networking |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 5분 |
| 네임스페이스 | cka-q093 |

## Context

애플리케이션이 외부 데이터베이스 `db.external-company.com`에 접근해야 합니다. 클러스터 내부에서 일관된 DNS 이름으로 외부 서비스에 접근할 수 있도록 ExternalName Service를 구성해야 합니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. 네임스페이스 `cka-q093`에 ExternalName Service를 생성하세요:
   - 이름: `external-db`
   - 타입: `ExternalName`
   - externalName: `db.external-company.com`

2. Service가 올바르게 생성되었는지 확인하세요:
   - `kubectl -n cka-q093 get svc external-db`

3. DNS 해석 테스트:
   - 클러스터 내부에서 `external-db.cka-q093.svc.cluster.local`을 조회하면 `db.external-company.com`의 CNAME이 반환되어야 함

## Expected Outcome

- Service `external-db` 타입이 `ExternalName`
- externalName이 `db.external-company.com`
- DNS 조회 시 CNAME 레코드 반환

<details>
<summary>힌트 1</summary>

ExternalName Service는 selector가 없으며, 외부 DNS 이름에 대한 CNAME 레코드를 생성합니다.

</details>

<details>
<summary>힌트 2</summary>

```yaml
apiVersion: v1
kind: Service
metadata:
  name: external-db
spec:
  type: ExternalName
  externalName: db.external-company.com
```

</details>

<details>
<summary>힌트 3</summary>

ExternalName Service는 ClusterIP를 할당받지 않습니다. `kubectl get svc`에서 EXTERNAL-IP 컬럼에 외부 도메인이 표시됩니다.

</details>
