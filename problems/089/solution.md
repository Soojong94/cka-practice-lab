# Problem 089: 정답 풀이

## Step 1: HTTPRoute 생성

```bash
kubectl -n cka-q089 apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: api-routes
spec:
  parentRefs:
  - name: api-gateway
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /v1
    backendRefs:
    - name: svc-v1
      port: 80
  - matches:
    - path:
        type: PathPrefix
        value: /v2
    backendRefs:
    - name: svc-v2
      port: 80
EOF
```

## 검증

```bash
kubectl -n cka-q089 get httproute api-routes
kubectl -n cka-q089 describe httproute api-routes
```
