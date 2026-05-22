# Problem 081: 정답 풀이

## Step 1: ClusterIP Service 생성

```bash
kubectl -n cka-q081 apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: web-svc
spec:
  type: ClusterIP
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 80
EOF
```

또는:

```bash
kubectl -n cka-q081 expose deployment web --name=web-svc --port=80 --target-port=80
```

## Step 2: Endpoints 확인

```bash
kubectl -n cka-q081 get endpoints web-svc
# 2개의 Pod IP가 표시되어야 함
```

## Step 3: 테스트 Pod 생성 및 curl 테스트

```bash
kubectl -n cka-q081 run test-pod --image=curlimages/curl:latest --restart=Never \
  --command -- sleep 3600
kubectl -n cka-q081 wait --for=condition=Ready pod/test-pod --timeout=30s

# curl 테스트
kubectl -n cka-q081 exec test-pod -- curl -s http://web-svc.cka-q081.svc.cluster.local
```

## Step 4: ConfigMap에 결과 저장

```bash
RESULT=$(kubectl -n cka-q081 exec test-pod -- curl -s http://web-svc.cka-q081.svc.cluster.local)
kubectl -n cka-q081 create configmap curl-result --from-literal=result="$RESULT"
```

## 검증

```bash
kubectl -n cka-q081 get svc web-svc
kubectl -n cka-q081 get endpoints web-svc
kubectl -n cka-q081 get configmap curl-result -o yaml
```
