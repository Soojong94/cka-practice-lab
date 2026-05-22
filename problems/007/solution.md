# Problem 007: 정답 풀이

## Step 1: Secret 생성

```bash
kubectl -n cka-q007 create secret generic db-credentials \
  --from-literal=username=admin \
  --from-literal=password='s3cur3P@ss'
```

## Step 2: 기존 Pod 삭제

```bash
kubectl -n cka-q007 delete pod db-app
```

## Step 3: Secret을 볼륨 + 환경변수로 사용하는 Pod 생성

```bash
kubectl -n cka-q007 apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: db-app
  labels:
    app: db-app
spec:
  containers:
  - name: db-app
    image: busybox:1.36
    command: ["sleep", "3600"]
    env:
    - name: DB_USER
      valueFrom:
        secretKeyRef:
          name: db-credentials
          key: username
    - name: DB_PASS
      valueFrom:
        secretKeyRef:
          name: db-credentials
          key: password
    volumeMounts:
    - name: secret-vol
      mountPath: /etc/secrets
      readOnly: true
  volumes:
  - name: secret-vol
    secret:
      secretName: db-credentials
EOF
```

## Step 4: 검증

```bash
# Pod 상태 확인
kubectl -n cka-q007 get pod db-app

# 볼륨 마운트 확인
kubectl -n cka-q007 exec db-app -- cat /etc/secrets/username
# 출력: admin

kubectl -n cka-q007 exec db-app -- cat /etc/secrets/password
# 출력: s3cur3P@ss

# 환경변수 확인
kubectl -n cka-q007 exec db-app -- env | grep DB_
# 출력:
# DB_USER=admin
# DB_PASS=s3cur3P@ss
```
