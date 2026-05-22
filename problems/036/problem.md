# Problem 036: Init Container 실패로 Pod 미시작

| 항목 | 값 |
|------|-----|
| 문제 번호 | 036 |
| 도메인 | Troubleshooting |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 7분 |
| 네임스페이스 | cka-q036 |

## Context

네임스페이스 `cka-q036`에 `app-pod`이 배포되었으나, Init Container가 완료되지 않아 메인 컨테이너가 시작되지 않고 있습니다. Init Container는 `init-svc`라는 서비스의 DNS 조회가 성공할 때까지 대기합니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. Pod `app-pod`의 상태를 확인하고, Init Container가 왜 완료되지 않는지 분석하세요.
   - `kubectl describe pod`로 Init Container 상태 확인
   - `kubectl logs app-pod -c init-check`로 로그 확인

2. Init Container가 기다리는 서비스 `init-svc`를 확인하세요.
   - 현재 네임스페이스에 해당 서비스가 존재하지 않음

3. 서비스 `init-svc`를 생성하세요:
   - 이름: `init-svc`
   - 포트: 80
   - 아무 selector나 설정 (예: `app: init-svc`)

4. Init Container가 완료되고 Pod가 `Running` 상태가 되는지 확인하세요.

## Expected Outcome

- Service `init-svc`가 네임스페이스 `cka-q036`에 존재
- Pod `app-pod`이 `Running` 상태 (Init Container 완료, 메인 컨테이너 시작)

<details>
<summary>힌트 1</summary>

`kubectl -n cka-q036 describe pod app-pod`에서 Init Containers 섹션을 확인합니다. State가 `Waiting` 또는 `Running`이면 아직 완료되지 않은 것입니다.

</details>

<details>
<summary>힌트 2</summary>

Init Container의 `nslookup init-svc.cka-q036.svc.cluster.local` 명령이 성공하려면 해당 이름의 Service가 존재해야 합니다. Service에 실제 Pod가 연결될 필요는 없습니다.

</details>

<details>
<summary>힌트 3</summary>

```bash
kubectl -n cka-q036 create service clusterip init-svc --tcp=80:80
```
또는:
```yaml
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
```

</details>
