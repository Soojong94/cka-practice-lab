# Problem 098: 정답 풀이

## Step 1: ClusterIP Service (internalTrafficPolicy: Local)

```bash
kubectl -n cka-q098 apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: web-internal
spec:
  type: ClusterIP
  selector:
    app: web-app
  ports:
  - port: 80
    targetPort: 80
  internalTrafficPolicy: Local
EOF
```

## Step 2: NodePort Service (externalTrafficPolicy: Local)

```bash
kubectl -n cka-q098 apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: web-external
spec:
  type: NodePort
  selector:
    app: web-app
  ports:
  - port: 80
    targetPort: 80
  externalTrafficPolicy: Local
EOF
```

## 검증

```bash
kubectl -n cka-q098 get svc web-internal -o jsonpath='{.spec.internalTrafficPolicy}'
kubectl -n cka-q098 get svc web-external -o jsonpath='{.spec.externalTrafficPolicy}'
```
