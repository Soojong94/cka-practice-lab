# Problem 091: 정답 풀이

## Step 1: Ingress 생성

```bash
kubectl -n cka-q091 apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
spec:
  rules:
  - host: app.example.com
    http:
      paths:
      - path: /app1
        pathType: Prefix
        backend:
          service:
            name: app1-svc
            port:
              number: 80
      - path: /app2
        pathType: Prefix
        backend:
          service:
            name: app2-svc
            port:
              number: 80
EOF
```

## 검증

```bash
kubectl -n cka-q091 get ingress app-ingress
kubectl -n cka-q091 describe ingress app-ingress
```
