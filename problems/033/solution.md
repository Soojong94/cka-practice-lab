# Problem 033: 정답 풀이

## Step 1: 현재 Ingress 설정 확인

```bash
kubectl -n cka-q033 get ingress web-ingress -o yaml
```

문제점:
- `pathType: Exact` → `/app` 정확히 일치만 매칭 (하위 경로 불가)
- `port.number: 8080` → Service는 80에서 동작하므로 잘못됨

## Step 2: Ingress 수정

```bash
kubectl -n cka-q033 edit ingress web-ingress
```

또는 patch 명령:

```bash
kubectl -n cka-q033 patch ingress web-ingress --type='json' -p='[
  {"op": "replace", "path": "/spec/rules/0/http/paths/0/pathType", "value": "Prefix"},
  {"op": "replace", "path": "/spec/rules/0/http/paths/0/backend/service/port/number", "value": 80}
]'
```

## Step 3: 수정 확인

```bash
kubectl -n cka-q033 get ingress web-ingress -o yaml
```

수정된 설정:
```yaml
spec:
  rules:
  - host: web-app.example.com
    http:
      paths:
      - path: /app
        pathType: Prefix
        backend:
          service:
            name: web-svc
            port:
              number: 80
```

## 검증

```bash
kubectl -n cka-q033 get ingress web-ingress
kubectl -n cka-q033 describe ingress web-ingress
```
