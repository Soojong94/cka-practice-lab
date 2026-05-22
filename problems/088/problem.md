# Problem 088: Gateway API - GatewayClass/Gateway 구성

| 항목 | 값 |
|------|-----|
| 문제 번호 | 088 |
| 도메인 | Services & Networking |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 10분 |
| 네임스페이스 | cka-q088 |

## Context

Kubernetes Gateway API는 Ingress의 차세대 대안으로, 더 풍부한 라우팅 기능을 제공합니다. Gateway API CRDs가 클러스터에 설치되어 있습니다. GatewayClass와 Gateway 리소스를 생성해야 합니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. GatewayClass `example-gc`를 생성하세요:
   - 이름: `example-gc`
   - controllerName: `example.com/gateway-controller`

2. 네임스페이스 `cka-q088`에 Gateway `main-gateway`를 생성하세요:
   - 이름: `main-gateway`
   - gatewayClassName: `example-gc`
   - listener 이름: `http`
   - protocol: `HTTP`
   - port: `80`

3. Gateway가 올바르게 생성되었는지 확인하세요.

## Expected Outcome

- `kubectl get gatewayclass example-gc` 존재
- `kubectl -n cka-q088 get gateway main-gateway` 존재
- Gateway의 listener가 HTTP port 80으로 설정됨

<details>
<summary>힌트 1</summary>

GatewayClass는 클러스터 범위 리소스입니다. `spec.controllerName`은 이 GatewayClass를 관리할 컨트롤러를 지정합니다.

</details>

<details>
<summary>힌트 2</summary>

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: example-gc
spec:
  controllerName: example.com/gateway-controller
```

</details>

<details>
<summary>힌트 3</summary>

Gateway의 listener 설정:
```yaml
listeners:
- name: http
  protocol: HTTP
  port: 80
```

</details>
