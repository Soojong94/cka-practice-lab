# Problem 050: Pod Priority와 Preemption

| 항목 | 값 |
|------|-----|
| 문제 번호 | 050 |
| 도메인 | Workloads & Scheduling |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 8분 |
| 네임스페이스 | cka-q050 |

## Context

클러스터에 PriorityClass `high-priority`가 생성되어 있습니다. Pod Priority를 사용하여 중요한 Pod가 우선적으로 스케줄링되도록 설정하세요.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. 네임스페이스 `cka-q050`에 Pod `important-pod`를 생성하세요:
   - 이미지: `nginx:1-alpine`
   - priorityClassName: `high-priority`

2. 네임스페이스 `cka-q050`에 Pod `normal-pod`를 생성하세요:
   - 이미지: `nginx:1-alpine`
   - priorityClassName 설정하지 않음 (기본 우선순위)

3. 각 Pod의 priority 값을 확인하세요:
   - `important-pod`: priority 값이 1000000
   - `normal-pod`: priority 값이 0

4. PriorityClass `high-priority`의 설정을 확인하세요.

## Expected Outcome

- PriorityClass `high-priority` 존재 (value: 1000000)
- `important-pod`에 priorityClassName `high-priority` 설정됨
- `important-pod`의 priority 값이 1000000
- `normal-pod`의 priority 값이 0

<details>
<summary>힌트 1</summary>

Pod에 PriorityClass를 지정하려면 `spec.priorityClassName`을 사용합니다:
```yaml
spec:
  priorityClassName: high-priority
```

</details>

<details>
<summary>힌트 2</summary>

Pod의 priority 값 확인:
```bash
kubectl -n cka-q050 get pod important-pod -o jsonpath='{.spec.priority}'
kubectl -n cka-q050 get pod normal-pod -o jsonpath='{.spec.priority}'
```

</details>

<details>
<summary>힌트 3</summary>

PriorityClass 확인:
```bash
kubectl get priorityclass high-priority
kubectl get priorityclass high-priority -o yaml
```

</details>
