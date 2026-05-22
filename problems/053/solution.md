# Problem 053: 정답 풀이

## Step 1: app-pod 생성 (initContainer 포함)

```bash
kubectl -n cka-q053 apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
  namespace: cka-q053
spec:
  initContainers:
  - name: wait-for-db
    image: busybox
    command: ["/bin/sh", "-c", "until nslookup db-service.cka-q053.svc.cluster.local; do echo waiting for db-service; sleep 2; done"]
  containers:
  - name: app
    image: nginx:1-alpine
EOF
```

## Step 2: Init 상태 확인

```bash
# Pod가 Init:0/1 상태인지 확인
kubectl -n cka-q053 get pod app-pod
# 출력: app-pod   0/1   Init:0/1   0   ...
```

## Step 3: db-pod 및 db-service 생성

```bash
# db-pod 생성
kubectl -n cka-q053 run db-pod --image=nginx:1-alpine --labels=app=db

# db-service 생성
kubectl -n cka-q053 apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: db-service
  namespace: cka-q053
spec:
  selector:
    app: db
  ports:
  - port: 80
    targetPort: 80
EOF
```

## Step 4: app-pod Running 확인

```bash
# 잠시 대기 후 확인
sleep 10
kubectl -n cka-q053 get pod app-pod
# 출력: app-pod   1/1   Running   0   ...
```

## 핵심 개념

- Init Container: 메인 컨테이너 시작 전에 실행되는 초기화 컨테이너
- 모든 Init Container가 성공해야 메인 컨테이너가 시작됨
- 서비스 의존성 대기, 설정 파일 생성, DB 마이그레이션 등에 활용
- nslookup으로 Service DNS 확인 가능 (Service가 생성되면 DNS 레코드 생김)
- Init Container는 순서대로 실행됨 (여러 개 설정 가능)
