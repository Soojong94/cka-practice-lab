# Problem 065: Operator 설치 및 설정 (시뮬레이션)

| 항목 | 값 |
|------|-----|
| 문제 번호 | 065 |
| 도메인 | Cluster Architecture, Installation & Configuration |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 10분 |
| 네임스페이스 | cka-q065 |

## Context

네임스페이스 `cka-q065`에 CRD `apps.operator.example.com`이 등록되어 있고, 이 CRD를 감시하는 간단한 컨트롤러 Deployment `app-controller`가 실행 중입니다. 컨트롤러는 새로운 CR이 생성되면 로그에 기록합니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. CRD `apps.operator.example.com`이 정상적으로 등록되어 있는지 확인하고, ConfigMap `operator-verify`의 `crd-exists` 키에 `true` 또는 `false`를 저장하세요.

2. 다음 스펙으로 Custom Resource를 생성하세요:
   - apiVersion: `operator.example.com/v1`
   - kind: `App`
   - 이름: `my-app`
   - spec.appName: `web-frontend`
   - spec.replicas: `2`
   - spec.image: `nginx:alpine`

3. 컨트롤러 Deployment `app-controller`가 Running 상태인지 확인하고, ConfigMap `operator-verify`의 `controller-running` 키에 `true` 또는 `false`를 저장하세요.

4. 컨트롤러 로그에서 `my-app` CR 감지 메시지를 확인하고, ConfigMap `operator-verify`의 `cr-detected` 키에 `true` 또는 `false`를 저장하세요.

## Expected Outcome

- ConfigMap `operator-verify`의 `crd-exists` = `true`
- Custom Resource `my-app` 존재
- ConfigMap `operator-verify`의 `controller-running` = `true`
- ConfigMap `operator-verify`의 `cr-detected` = `true`

<details>
<summary>힌트 1</summary>

CRD 존재 확인:
```bash
kubectl get crd apps.operator.example.com &>/dev/null && echo "true" || echo "false"
```

</details>

<details>
<summary>힌트 2</summary>

Custom Resource 생성:
```yaml
apiVersion: operator.example.com/v1
kind: App
metadata:
  name: my-app
  namespace: cka-q065
spec:
  appName: web-frontend
  replicas: 2
  image: nginx:alpine
```

</details>

<details>
<summary>힌트 3</summary>

컨트롤러 로그 확인:
```bash
kubectl -n cka-q065 logs deployment/app-controller | grep "my-app"
```

</details>
