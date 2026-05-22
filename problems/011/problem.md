# Problem 011: CrashLoopBackOff Pod 디버깅

| 항목 | 값 |
|------|-----|
| 문제 번호 | 011 |
| 도메인 | Troubleshooting |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 5분 |
| 네임스페이스 | cka-q011 |

## Context

네임스페이스 `cka-q011`에 `crash-pod`라는 Pod가 배포되었으나, CrashLoopBackOff 상태에 빠져 있습니다. 운영팀에서 이 Pod가 정상적으로 실행되도록 수정을 요청했습니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. `crash-pod`의 상태를 확인하고, CrashLoopBackOff의 원인을 파악하세요.

2. Pod의 로그를 확인하여 어떤 에러가 발생하는지 분석하세요.

3. Pod의 컨테이너 커맨드를 올바르게 수정하여 Pod가 `Running` 상태가 되도록 하세요.
   - 올바른 커맨드: `sleep 3600`

## Expected Outcome

- `kubectl -n cka-q011 get pod crash-pod` 실행 시 STATUS가 `Running`
- Pod가 정상적으로 `sleep 3600` 커맨드를 실행 중

<details>
<summary>힌트 1</summary>

`kubectl -n cka-q011 describe pod crash-pod`로 이벤트를 확인하고, `kubectl -n cka-q011 logs crash-pod`로 로그를 확인하세요.

</details>

<details>
<summary>힌트 2</summary>

Pod의 command 필드에 오타가 있습니다. 실행 중인 Pod의 spec은 직접 수정할 수 없으므로, Pod를 삭제하고 올바른 command로 다시 생성해야 합니다.

</details>

<details>
<summary>힌트 3</summary>

```bash
kubectl -n cka-q011 get pod crash-pod -o yaml > /tmp/crash-pod.yaml
# command를 "sleep"으로 수정
kubectl -n cka-q011 delete pod crash-pod --grace-period=0 --force
kubectl -n cka-q011 apply -f /tmp/crash-pod.yaml
```

</details>
