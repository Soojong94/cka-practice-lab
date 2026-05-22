# Problem 092: 정답 풀이

## Step 1: ConfigMap에서 인증서 추출

```bash
kubectl -n cka-q092 get configmap tls-files -o jsonpath='{.data.tls\.crt}' > /tmp/tls.crt
kubectl -n cka-q092 get configmap tls-files -o jsonpath='{.data.tls\.key}' > /tmp/tls.key
```

## Step 2: TLS Secret 생성

```bash
kubectl -n cka-q092 create secret tls secure-tls --cert=/tmp/tls.crt --key=/tmp/tls.key
```

## Step 3: Ingress 생성 (TLS 포함)

```bash
kubectl -n cka-q092 apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: secure-ingress
spec:
  tls:
  - hosts:
    - secure.example.com
    secretName: secure-tls
  rules:
  - host: secure.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: secure-app-svc
            port:
              number: 80
EOF
```

## 검증

```bash
kubectl -n cka-q092 get secret secure-tls
kubectl -n cka-q092 get ingress secure-ingress
kubectl -n cka-q092 describe ingress secure-ingress
```
