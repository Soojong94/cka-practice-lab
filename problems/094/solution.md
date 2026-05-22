# Problem 094: 정답 풀이

## Step 1: Service selector 확인

```bash
kubectl -n cka-q094 get svc legacy-svc -o yaml
# spec.selector가 없음을 확인
```

## Step 2: Endpoints 수동 생성

```bash
kubectl -n cka-q094 apply -f - <<EOF
apiVersion: v1
kind: Endpoints
metadata:
  name: legacy-svc
subsets:
- addresses:
  - ip: 10.0.0.100
  ports:
  - port: 8080
EOF
```

## Step 3: 확인

```bash
kubectl -n cka-q094 get endpoints legacy-svc
kubectl -n cka-q094 describe svc legacy-svc
```

## 검증

```bash
kubectl -n cka-q094 get endpoints legacy-svc -o yaml
```
