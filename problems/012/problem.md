# Problem 012: ImagePullBackOff 해결

| 항목 | 값 |
|------|-----|
| 문제 번호 | 012 |
| 도메인 | Troubleshooting |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 5분 |
| 네임스페이스 | cka-q012 |

## Context

네임스페이스 `cka-q012`에 `web-deploy`라는 Deployment가 배포되었으나, Pod들이 ImagePullBackOff 상태에 빠져 있습니다. 운영팀에서 이 Deployment가 정상적으로 실행되도록 수정을 요청했습니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. `web-deploy` Deployment의 Pod 상태를 확인하고, ImagePullBackOff의 원인을 파악하세요.

2. Pod의 이벤트를 확인하여 어떤 이미지를 pull하려다 실패했는지 분석하세요.

3. Deployment의 컨테이너 이미지를 올바른 이미지 이름 `nginx:latest`로 수정하세요.

4. 수정 후 모든 Pod가 Running 상태이고 Deployment가 Available 상태인지 확인하세요.

## Expected Outcome

- `kubectl -n cka-q012 get deployment web-deploy` 실행 시 AVAILABLE이 3
- 모든 Pod가 Running 상태

<details>
<summary>힌트 1</summary>

`kubectl -n cka-q012 describe pod <pod-name>`으로 이벤트를 확인하면 이미지 이름에 오타가 있음을 알 수 있습니다.

</details>

<details>
<summary>힌트 2</summary>

`kubectl -n cka-q012 set image deployment/web-deploy nginx=nginx:latest` 명령으로 이미지를 수정할 수 있습니다.

</details>

<details>
<summary>힌트 3</summary>

또는 `kubectl -n cka-q012 edit deployment web-deploy`로 직접 이미지 이름을 수정할 수 있습니다. `ngnix:latest` → `nginx:latest`

</details>
