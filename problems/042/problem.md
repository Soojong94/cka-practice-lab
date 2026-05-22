# Problem 042: Pod Anti-Affinity로 분산 배치

| 항목 | 값 |
|------|-----|
| 문제 번호 | 042 |
| 도메인 | Workloads & Scheduling |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 8분 |
| 네임스페이스 | cka-q042 |

## Context

네임스페이스 `cka-q042`에 고가용성을 위해 Pod를 가능한 한 서로 다른 노드에 분산 배치해야 합니다. Pod Anti-Affinity를 사용하여 동일 호스트에 같은 앱의 Pod가 배치되지 않도록 선호(preferred) 규칙을 설정하세요.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. 네임스페이스 `cka-q042`에 다음 스펙으로 Deployment를 생성하세요:
   - 이름: `spread-app`
   - 이미지: `nginx:1-alpine`
   - 레플리카: `3`
   - Pod 레이블: `app=spread-app`

2. Pod Anti-Affinity를 설정하세요 (preferredDuringSchedulingIgnoredDuringExecution):
   - weight: `100`
   - topologyKey: `kubernetes.io/hostname`
   - labelSelector matchLabels: `app=spread-app`

3. 모든 Pod가 Running 상태인지 확인하세요 (단일 노드 환경에서는 preferred이므로 모두 같은 노드에 스케줄됨).

## Expected Outcome

- `kubectl -n cka-q042 get deployment spread-app` 실행 시 3/3 READY
- Deployment spec에 podAntiAffinity 설정이 올바르게 포함됨
- 단일 노드 환경에서도 모든 Pod가 Running 상태

<details>
<summary>힌트 1</summary>

`preferredDuringSchedulingIgnoredDuringExecution`은 소프트 규칙으로, 조건을 만족하지 못해도 Pod가 스케줄됩니다. 단일 노드 환경에서는 이 옵션을 사용해야 합니다.

</details>

<details>
<summary>힌트 2</summary>

Pod Anti-Affinity 설정 예시:

```yaml
spec:
  template:
    spec:
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchLabels:
                  app: spread-app
              topologyKey: kubernetes.io/hostname
```

</details>

<details>
<summary>힌트 3</summary>

`requiredDuringSchedulingIgnoredDuringExecution`을 사용하면 단일 노드에서는 1개의 Pod만 스케줄되고 나머지는 Pending 상태가 됩니다.

</details>
