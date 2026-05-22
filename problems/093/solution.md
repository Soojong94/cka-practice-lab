# Problem 093: 정답 풀이

## Step 1: ExternalName Service 생성

```bash
kubectl -n cka-q093 apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: external-db
spec:
  type: ExternalName
  externalName: db.external-company.com
EOF
```

## Step 2: 확인

```bash
kubectl -n cka-q093 get svc external-db
```

## Step 3: DNS 해석 테스트

```bash
kubectl -n cka-q093 run dns-test --image=busybox:1.36 --rm -it --restart=Never \
  -- nslookup external-db.cka-q093.svc.cluster.local
# CNAME으로 db.external-company.com이 반환됨
```

## 검증

```bash
kubectl -n cka-q093 get svc external-db -o yaml
```
