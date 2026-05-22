# Problem 100: 정답 풀이

## Step 1: Backend 네임스페이스 - allow-from-frontend

```bash
kubectl -n cka-q100-backend apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-from-frontend
spec:
  podSelector:
    matchLabels:
      role: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: cka-q100-frontend
    ports:
    - protocol: TCP
      port: 8080
EOF
```

## Step 2: DB 네임스페이스 - allow-from-backend

```bash
kubectl -n cka-q100-db apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-from-backend
spec:
  podSelector:
    matchLabels:
      role: db
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: cka-q100-backend
    ports:
    - protocol: TCP
      port: 5432
EOF
```

## Step 3: DB 네임스페이스 - default-deny-ingress

```bash
kubectl -n cka-q100-db apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
spec:
  podSelector: {}
  policyTypes:
  - Ingress
EOF
```

## 검증

```bash
kubectl -n cka-q100-backend get networkpolicy
kubectl -n cka-q100-db get networkpolicy
kubectl -n cka-q100-backend describe networkpolicy allow-from-frontend
kubectl -n cka-q100-db describe networkpolicy allow-from-backend
kubectl -n cka-q100-db describe networkpolicy default-deny-ingress
```
