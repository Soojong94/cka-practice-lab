# Problem 051: Topology Spread Constraints

| 항목 | 값 |
|------|-----|
| 문제 번호 | 051 |
| 도메인 | Workloads & Scheduling |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 8분 |
| 네임스페이스 | cka-q051 |

## Context

네임스페이스 `cka-q051`에 Pod를 토폴로지 도메인(zone) 기준으로 균등하게 분산 배치해야 합니다. Topology Spread Constraints를 사용하여 Pod가 가능한 한 균등하게 분산되도록 설정하세요.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. 네임스페이스 `cka-q051`에 다음 스펙으로 Deployment를 생성하세요:
   - 이름: `balanced-app`
   - 이미지: `nginx:1-alpine`
   - 레플리카: `3`
   - Pod 레이블: `app=balanced-app`

2. topologySpreadConstraints를 설정하세요:
   - maxSkew: `1`
   - topologyKey: `topology.kubernetes.io/zone`
   - whenUnsatisfiable: `ScheduleAnyway`
   - labelSelector matchLabels: `app=balanced-app`

3. 모든 Pod가 Running 상태인지 확인하세요.

## Expected Outcome

- Deployment `balanced-app`에 topologySpreadConstraints 설정됨
- maxSkew=1, topologyKey=topology.kubernetes.io/zone
- whenUnsatisfiable=ScheduleAnyway (단일 노드에서도 스케줄 가능)
- 모든 Pod Running 상태

<details>
<summary>힌트 1</summary>

Topology Spread Constraints는 Pod를 토폴로지 도메인 간에 균등하게 분산합니다. `whenUnsatisfiable: ScheduleAnyway`는 소프트 규칙으로, 조건을 만족하지 못해도 스케줄됩니다.

</details>

<details>
<summary>힌트 2</summary>

```yaml
spec:
  template:
    spec:
      topologySpreadConstraints:
      - maxSkew: 1
        topologyKey: topology.kubernetes.io/zone
        whenUnsatisfiable: ScheduleAnyway
        labelSelector:
          matchLabels:
            app: balanced-app
```

</details>

<details>
<summary>힌트 3</summary>

- `maxSkew`: 토폴로지 도메인 간 Pod 수 차이의 최대값
- `DoNotSchedule`: 하드 규칙 (조건 불만족 시 Pending)
- `ScheduleAnyway`: 소프트 규칙 (가능한 한 균등하게, 불가능하면 어디든 스케줄)

</details>
