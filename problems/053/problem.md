# Problem 053: Init Container로 의존성 대기

| 항목 | 값 |
|------|-----|
| 문제 번호 | 053 |
| 도메인 | Workloads & Scheduling |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 10분 |
| 네임스페이스 | cka-q053 |

## Context

네임스페이스 `cka-q053`에 데이터베이스 서비스에 의존하는 애플리케이션을 배포해야 합니다. Init Container를 사용하여 데이터베이스 서비스가 준비될 때까지 대기한 후 메인 컨테이너를 시작하세요.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. 네임스페이스 `cka-q053`에 Pod `app-pod`를 생성하세요:
   - 메인 컨테이너:
     - 이름: `app`
     - 이미지: `nginx:1-alpine`
   - Init Container:
     - 이름: `wait-for-db`
     - 이미지: `busybox`
     - command: `["/bin/sh", "-c", "until nslookup db-service.cka-q053.svc.cluster.local; do echo waiting for db-service; sleep 2; done"]`

2. Pod가 Init 상태에서 대기하는 것을 확인하세요 (db-service가 아직 없으므로).

3. 더미 Pod와 Service를 생성하여 initContainer가 완료되도록 하세요:
   - Pod 이름: `db-pod`, 이미지: `nginx:1-alpine`, 레이블: `app=db`
   - Service 이름: `db-service`, selector: `app=db`, port: 80

4. `app-pod`가 Running 상태가 되었는지 확인하세요.

## Expected Outcome

- Pod `app-pod`에 initContainer `wait-for-db`가 설정됨
- Service `db-service`가 존재하고 `db-pod`에 연결됨
- `app-pod`가 Running 상태 (initContainer 완료 후)

<details>
<summary>힌트 1</summary>

Init Container는 메인 컨테이너가 시작되기 전에 실행되며, 성공적으로 완료되어야 메인 컨테이너가 시작됩니다. 서비스 의존성 대기에 자주 사용됩니다.

</details>

<details>
<summary>힌트 2</summary>

```yaml
spec:
  initContainers:
  - name: wait-for-db
    image: busybox
    command: ["/bin/sh", "-c", "until nslookup db-service.cka-q053.svc.cluster.local; do echo waiting; sleep 2; done"]
  containers:
  - name: app
    image: nginx:1-alpine
```

</details>

<details>
<summary>힌트 3</summary>

Service를 생성하면 DNS 레코드가 생기므로 nslookup이 성공합니다:
```bash
kubectl -n cka-q053 create service clusterip db-service --tcp=80:80
kubectl -n cka-q053 run db-pod --image=nginx:1-alpine --labels=app=db
```

</details>
