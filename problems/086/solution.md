# Problem 086: 정답 풀이

## Step 1: NetworkPolicy 생성

```bash
kubectl -n cka-q086 apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: app-egress
spec:
  podSelector:
    matchLabels:
      role: app
  policyTypes:
  - Egress
  egress:
  - to:
    - podSelector:
        matchLabels:
          role: db
    ports:
    - protocol: TCP
      port: 5432
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
kubectl -n cka-q086 get networkpolicy app-egress -o yaml
kubectl -n cka-q086 describe networkpolicy app-egress
```
