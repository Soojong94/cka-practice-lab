# Problem 036: 정답 풀이

## Step 1: Pod 상태 확인

```bash
kubectl -n cka-q036 get pod app-pod
# STATUS: Init:0/1

kubectl -n cka-q036 describe pod app-pod
# Init Containers:
#   init-check:
#     State: Running (또는 Waiting)

kubectl -n cka-q036 logs app-pod -c init-check
# "Waiting for init-svc..."
# "nslookup: can't resolve 'init-svc.cka-q036.svc.cluster.local'"
```

## Step 2: 서비스 존재 확인

```bash
kubectl -n cka-q036 get svc
# init-svc가 없음
```

## Step 3: 서비스 생성

```bash
kubectl -n cka-q036 apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: init-svc
  namespace: cka-q036
spec:
  ports:
  - port: 80
    targetPort: 80
  selector:
    app: init-svc
EOF
```

또는 간단히:
```bash
kubectl -n cka-q036 create service clusterip init-svc --tcp=80:80
```

## Step 4: Pod Running 확인

```bash
# 잠시 대기 후 확인
sleep 10
kubectl -n cka-q036 get pod app-pod
# STATUS: Running
```

## 검증

```bash
kubectl -n cka-q036 get svc init-svc
kubectl -n cka-q036 get pod app-pod -o jsonpath='{.status.phase}'
# Running
```
