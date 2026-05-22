# Problem 088: 정답 풀이

## Step 1: GatewayClass 생성

```bash
kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: example-gc
spec:
  controllerName: example.com/gateway-controller
EOF
```

## Step 2: Gateway 생성

```bash
kubectl -n cka-q088 apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: main-gateway
spec:
  gatewayClassName: example-gc
  listeners:
  - name: http
    protocol: HTTP
    port: 80
EOF
```

## 검증

```bash
kubectl get gatewayclass example-gc
kubectl -n cka-q088 get gateway main-gateway
kubectl -n cka-q088 describe gateway main-gateway
```
