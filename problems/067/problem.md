# Problem 067: kubectl 정렬 및 jsonpath 출력

| 항목 | 값 |
|------|-----|
| 문제 번호 | 067 |
| 도메인 | Cluster Architecture, Installation & Configuration |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 8분 |
| 네임스페이스 | cka-q067 |

## Context

네임스페이스 `cka-q067`에 여러 Pod가 다른 시간에 생성되어 있습니다. kubectl의 고급 출력 옵션을 사용하여 정보를 추출해야 합니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. 네임스페이스 `cka-q067`의 모든 Pod를 생성 시간(`.metadata.creationTimestamp`) 기준으로 정렬하여 이름만 추출하고, 결과를 ConfigMap `kubectl-output`의 `sorted-pods` 키에 쉼표로 구분하여 저장하세요.

2. 모든 Pod의 이름과 IP를 custom-columns 형식으로 출력하는 kubectl 명령을 ConfigMap `kubectl-output`의 `custom-columns-cmd` 키에 저장하세요.
   - 형식: `kubectl -n cka-q067 get pods -o custom-columns=NAME:.metadata.name,IP:.status.podIP`

3. `pod-beta`의 `tier` 레이블 값을 jsonpath로 추출하여 ConfigMap `kubectl-output`의 `pod-beta-tier` 키에 저장하세요.

4. 네임스페이스 `cka-q067`에서 `tier=backend` 레이블을 가진 Pod 수를 ConfigMap `kubectl-output`의 `backend-count` 키에 저장하세요.

## Expected Outcome

- ConfigMap `kubectl-output`의 `sorted-pods`: 생성 시간 순서대로 Pod 이름 (쉼표 구분)
- ConfigMap `kubectl-output`의 `custom-columns-cmd`: 올바른 custom-columns 명령
- ConfigMap `kubectl-output`의 `pod-beta-tier`: `backend`
- ConfigMap `kubectl-output`의 `backend-count`: `2`

<details>
<summary>힌트 1</summary>

생성 시간 기준 정렬:
```bash
kubectl -n cka-q067 get pods --sort-by=.metadata.creationTimestamp -o jsonpath='{.items[*].metadata.name}'
```

</details>

<details>
<summary>힌트 2</summary>

custom-columns 사용:
```bash
kubectl -n cka-q067 get pods -o custom-columns=NAME:.metadata.name,IP:.status.podIP
```

</details>

<details>
<summary>힌트 3</summary>

jsonpath로 특정 값 추출:
```bash
kubectl -n cka-q067 get pod pod-beta -o jsonpath='{.metadata.labels.tier}'
```

</details>
