# Problem 085: 정답 풀이

## Step 1: NetworkPolicy 생성

```bash
kubectl -n cka-q085 apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend
spec:
  podSelector:
    matchLabels:
      role: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: frontend
    ports:
    - protocol: TCP
      port: 80
EOF
```

## Step 2: 접근 테스트

```bash
# backend Pod IP 확인
BACKEND_IP=$(kubectl -n cka-q085 get pod backend -o jsonpath='{.status.podIP}')

# frontend에서 접근 (허용됨)
kubectl -n cka-q085 exec frontend -- curl -s --max-time 3 http://$BACKEND_IP

# other에서 접근 (차단됨 - NetworkPolicy CNI가 지원하는 경우)
kubectl -n cka-q085 exec other -- curl -s --max-time 3 http://$BACKEND_IP
```

## 검증

```bash
kubectl -n cka-q085 get networkpolicy allow-frontend -o yaml
kubectl -n cka-q085 describe networkpolicy allow-frontend
```
