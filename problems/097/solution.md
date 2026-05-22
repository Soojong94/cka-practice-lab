# Problem 097: 정답 풀이

## Step 1: Multi-port Service 생성

```bash
kubectl -n cka-q097 apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: multi-port-svc
spec:
  selector:
    app: multi-app
  ports:
  - name: http
    port: 80
    targetPort: 80
  - name: https
    port: 443
    targetPort: 443
EOF
```

## 검증

```bash
kubectl -n cka-q097 get svc multi-port-svc
kubectl -n cka-q097 describe svc multi-port-svc
kubectl -n cka-q097 get endpoints multi-port-svc
```
