# Problem 090: 정답 풀이

## Step 1: HTTPRoute 생성 (헤더 기반 라우팅)

```bash
kubectl -n cka-q090 apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: device-route
spec:
  parentRefs:
  - name: header-gateway
  rules:
  - matches:
    - headers:
      - type: RegularExpression
        name: User-Agent
        value: ".*Mobile.*"
    backendRefs:
    - name: mobile-svc
      port: 80
  - backendRefs:
    - name: desktop-svc
      port: 80
EOF
```

## 검증

```bash
kubectl -n cka-q090 get httproute device-route
kubectl -n cka-q090 describe httproute device-route
```
