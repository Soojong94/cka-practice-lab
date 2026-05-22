# Problem 013: Pending Pod 원인 분석 및 해결

| 항목 | 값 |
|------|-----|
| 문제 번호 | 013 |
| 도메인 | Troubleshooting |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 8분 |
| 네임스페이스 | cka-q013 |

## Context

네임스페이스 `cka-q013`에 두 개의 Pod(`memory-hog`, `node-selector-pod`)가 배포되었으나, 모두 Pending 상태에 머물러 있습니다. 각 Pod의 스케줄링 실패 원인을 분석하고 해결하세요.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. `memory-hog` Pod의 Pending 원인을 파악하세요. (과도한 리소스 요청)

2. `memory-hog` Pod를 수정하여 스케줄링 가능하도록 메모리 요청을 `64Mi`로 변경하세요.

3. `node-selector-pod` Pod의 Pending 원인을 파악하세요. (존재하지 않는 nodeSelector)

4. `node-selector-pod` Pod를 수정하여 nodeSelector를 제거하고 정상 스케줄링되도록 하세요.

## Expected Outcome

- `kubectl -n cka-q013 get pod memory-hog` 실행 시 STATUS가 `Running`
- `kubectl -n cka-q013 get pod node-selector-pod` 실행 시 STATUS가 `Running`

<details>
<summary>힌트 1</summary>

`kubectl -n cka-q013 describe pod memory-hog`의 Events에서 `Insufficient memory` 메시지를 확인할 수 있습니다.

</details>

<details>
<summary>힌트 2</summary>

Pod의 spec은 직접 수정할 수 없으므로, Pod를 삭제하고 올바른 스펙으로 다시 생성해야 합니다.

```bash
kubectl -n cka-q013 delete pod memory-hog --grace-period=0 --force
```

</details>

<details>
<summary>힌트 3</summary>

`node-selector-pod`의 경우 `kubectl -n cka-q013 describe pod node-selector-pod`에서 `node(s) didn't match Pod's node affinity/selector` 메시지를 확인할 수 있습니다. nodeSelector를 제거하고 재생성하세요.

</details>
