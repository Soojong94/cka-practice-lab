# Problem 087: 정답 풀이

## Step 1: 기본 거부 정책 생성

```bash
kubectl -n cka-q087 apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
EOF
```

## Step 2: web → api 허용 정책

```bash
kubectl -n cka-q087 apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-web-to-api
spec:
  podSelector:
    matchLabels:
      role: api
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: web
    ports:
    - protocol: TCP
      port: 8080
EOF
```

## Step 3: api → db 허용 정책

```bash
kubectl -n cka-q087 apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-api-to-db
spec:
  podSelector:
    matchLabels:
      role: db
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: api
    ports:
    - protocol: TCP
      port: 5432
EOF
```

## Step 4: DNS egress 허용 (선택사항)

```bash
kubectl -n cka-q087 apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-dns
spec:
  podSelector: {}
  policyTypes:
  - Egress
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: kube-system
    ports:
    - protocol: UDP
      port: 53
    - protocol: TCP
      port: 53
EOF
```

## 검증

```bash
kubectl -n cka-q087 get networkpolicy
kubectl -n cka-q087 describe networkpolicy default-deny-all
kubectl -n cka-q087 describe networkpolicy allow-web-to-api
kubectl -n cka-q087 describe networkpolicy allow-api-to-db
```
