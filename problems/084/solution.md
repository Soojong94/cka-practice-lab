# Problem 084: 정답 풀이

## Step 1: Headless Service 생성

```bash
kubectl -n cka-q084 apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: db-headless
spec:
  clusterIP: None
  selector:
    app: db
  ports:
  - port: 5432
    targetPort: 5432
EOF
```

## Step 2: 개별 Pod DNS 확인

```bash
# 각 Pod의 DNS 해석 확인
kubectl -n cka-q084 run dns-check --image=busybox:1.36 --rm -it --restart=Never \
  -- nslookup db-0.db-headless.cka-q084.svc.cluster.local

kubectl -n cka-q084 run dns-check2 --image=busybox:1.36 --rm -it --restart=Never \
  -- nslookup db-1.db-headless.cka-q084.svc.cluster.local

kubectl -n cka-q084 run dns-check3 --image=busybox:1.36 --rm -it --restart=Never \
  -- nslookup db-2.db-headless.cka-q084.svc.cluster.local
```

## 검증

```bash
kubectl -n cka-q084 get svc db-headless
kubectl -n cka-q084 get endpoints db-headless
kubectl -n cka-q084 get pods -l app=db -o wide
```
