# Problem 043: Node Affinity 스케줄링

| 항목 | 값 |
|------|-----|
| 문제 번호 | 043 |
| 도메인 | Workloads & Scheduling |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 8분 |
| 네임스페이스 | cka-q043 |

## Context

클러스터의 노드에 `gpu=true` 레이블이 설정되어 있습니다. Node Affinity를 사용하여 특정 레이블이 있는 노드에만 Pod를 스케줄링하세요.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. 네임스페이스 `cka-q043`에 Pod `gpu-pod`를 생성하세요:
   - 이미지: `nginx:1-alpine`
   - nodeAffinity: `requiredDuringSchedulingIgnoredDuringExecution`
   - 조건: 노드 레이블 `gpu=true`인 노드에만 스케줄링
   - (matchExpressions: key=gpu, operator=In, values=[true])

2. 네임스페이스 `cka-q043`에 Pod `cpu-pod`를 생성하세요:
   - 이미지: `nginx:1-alpine`
   - nodeAffinity: `requiredDuringSchedulingIgnoredDuringExecution`
   - 조건: 노드 레이블 `gpu=false`인 노드에만 스케줄링
   - (matchExpressions: key=gpu, operator=In, values=[false])

3. `gpu-pod`가 Running 상태이고, `cpu-pod`가 Pending 상태인지 확인하세요.

## Expected Outcome

- `gpu-pod`: Running 상태 (gpu=true 레이블이 있는 노드에 스케줄됨)
- `cpu-pod`: Pending 상태 (gpu=false 레이블이 있는 노드가 없으므로 스케줄 불가)
- 각 Pod에 올바른 nodeAffinity 규칙이 설정됨

<details>
<summary>힌트 1</summary>

Node Affinity는 `spec.affinity.nodeAffinity`에 설정합니다. `requiredDuringSchedulingIgnoredDuringExecution`은 하드 규칙으로, 조건을 만족하는 노드가 없으면 Pod는 Pending 상태가 됩니다.

</details>

<details>
<summary>힌트 2</summary>

```yaml
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: gpu
            operator: In
            values:
            - "true"
```

</details>

<details>
<summary>힌트 3</summary>

Pod가 Pending인 이유를 확인하려면:
```bash
kubectl -n cka-q043 describe pod cpu-pod | grep -A5 Events
```

</details>
