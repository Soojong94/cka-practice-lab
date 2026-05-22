# Problem 097: Multi-port Service 구성

| 항목 | 값 |
|------|-----|
| 문제 번호 | 097 |
| 도메인 | Services & Networking |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 7분 |
| 네임스페이스 | cka-q097 |

## Context

네임스페이스 `cka-q097`에 `multi-app` Deployment가 동작 중입니다. 이 애플리케이션은 HTTP(80)와 HTTPS(443) 두 개의 포트를 노출합니다. 하나의 Service에서 두 포트를 모두 노출하는 Multi-port Service를 구성해야 합니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. 네임스페이스 `cka-q097`에 Multi-port Service를 생성하세요:
   - 이름: `multi-port-svc`
   - selector: `app: multi-app`

2. 포트 1:
   - name: `http`
   - port: `80`
   - targetPort: `80`

3. 포트 2:
   - name: `https`
   - port: `443`
   - targetPort: `443`

4. Service가 올바르게 생성되었는지 확인하세요.

## Expected Outcome

- Service `multi-port-svc`에 2개의 포트 정의
- 포트 이름: http(80), https(443)
- Endpoints에 두 포트 모두 등록

<details>
<summary>힌트 1</summary>

Multi-port Service에서는 각 포트에 반드시 `name` 필드를 지정해야 합니다.

</details>

<details>
<summary>힌트 2</summary>

```yaml
spec:
  ports:
  - name: http
    port: 80
    targetPort: 80
  - name: https
    port: 443
    targetPort: 443
```

</details>

<details>
<summary>힌트 3</summary>

포트가 2개 이상인 Service에서 name을 생략하면 에러가 발생합니다. 각 포트에 고유한 이름을 부여하세요.

</details>
