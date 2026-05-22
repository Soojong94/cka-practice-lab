# Problem 082: 정답 풀이

## Step 1: NodePort Service 생성

```bash
kubectl -n cka-q082 apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: api-nodeport
spec:
  type: NodePort
  selector:
    app: api
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
EOF
```

## Step 2: Endpoints 확인

```bash
kubectl -n cka-q082 get endpoints api-nodeport
```

## Step 3: NodePort 접근 테스트

```bash
curl http://localhost:30080
```

## 검증

```bash
kubectl -n cka-q082 get svc api-nodeport
kubectl -n cka-q082 describe svc api-nodeport
```
