# Problem 094: Endpoint/EndpointSlice 수동 구성

| 항목 | 값 |
|------|-----|
| 문제 번호 | 094 |
| 도메인 | Services & Networking |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 8분 |
| 네임스페이스 | cka-q094 |

## Context

네임스페이스 `cka-q094`에 selector가 없는 Service `legacy-svc`가 존재합니다. 이 Service는 클러스터 외부의 레거시 시스템(IP: 10.0.0.100, port: 8080)을 가리켜야 합니다. selector가 없으므로 Endpoints를 수동으로 생성해야 합니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. Service `legacy-svc`에 selector가 없는지 확인하세요.

2. Endpoints 리소스를 수동으로 생성하세요:
   - 이름: `legacy-svc` (Service 이름과 동일해야 함)
   - IP: `10.0.0.100`
   - port: `8080`

3. Endpoints가 Service에 연결되었는지 확인하세요:
   - `kubectl -n cka-q094 get endpoints legacy-svc`

## Expected Outcome

- Service `legacy-svc`에 selector 없음
- Endpoints `legacy-svc`에 IP 10.0.0.100, port 8080 등록
- `kubectl -n cka-q094 describe svc legacy-svc`에서 Endpoints 확인

<details>
<summary>힌트 1</summary>

selector가 없는 Service는 자동으로 Endpoints를 생성하지 않습니다. 같은 이름의 Endpoints 리소스를 수동으로 생성해야 합니다.

</details>

<details>
<summary>힌트 2</summary>

```yaml
apiVersion: v1
kind: Endpoints
metadata:
  name: legacy-svc
subsets:
- addresses:
  - ip: 10.0.0.100
  ports:
  - port: 8080
```

</details>

<details>
<summary>힌트 3</summary>

Endpoints 리소스의 이름은 반드시 Service 이름과 동일해야 합니다. 이것이 Service와 Endpoints를 연결하는 방법입니다.

</details>
