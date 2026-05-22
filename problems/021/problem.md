# Problem 021: Pod QoS 클래스 분석 및 종료 순서

| 항목 | 값 |
|------|-----|
| 문제 번호 | 021 |
| 도메인 | Troubleshooting |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 7분 |
| 네임스페이스 | cka-q021 |

## Context

네임스페이스 `cka-q021`에 3개의 Pod가 동작 중입니다. 클러스터의 메모리 압박(memory pressure) 상황에서 kubelet이 Pod를 종료하는 순서를 분석해야 합니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. 각 Pod의 QoS 클래스를 확인하세요:
   - `pod-guaranteed`
   - `pod-burstable`
   - `pod-besteffort`

2. 메모리 압박 시 kubelet이 **가장 먼저 종료**하는 Pod의 이름을 확인하세요.

3. 다음 스펙으로 ConfigMap을 생성하세요:
   - 이름: `qos-analysis`
   - 네임스페이스: `cka-q021`
   - 데이터:
     - `guaranteed`: Guaranteed QoS Pod 이름
     - `burstable`: Burstable QoS Pod 이름
     - `besteffort`: BestEffort QoS Pod 이름
     - `first-terminated`: 가장 먼저 종료되는 Pod 이름

4. QoS 종료 우선순위를 설명하는 키 `eviction-order`를 ConfigMap에 추가하세요:
   - 값: `BestEffort -> Burstable -> Guaranteed`

## Expected Outcome

- ConfigMap `qos-analysis`가 네임스페이스 `cka-q021`에 존재
- `first-terminated` 값이 BestEffort QoS Pod 이름과 일치
- `eviction-order` 값이 올바른 종료 순서를 포함

<details>
<summary>힌트 1</summary>

Pod의 QoS 클래스는 `kubectl get pod <name> -o jsonpath='{.status.qosClass}'`로 확인할 수 있습니다.

</details>

<details>
<summary>힌트 2</summary>

QoS 종료 우선순위: BestEffort (가장 먼저) → Burstable → Guaranteed (가장 나중에)

리소스 requests/limits가 없는 Pod가 BestEffort, requests만 있거나 requests < limits인 Pod가 Burstable, requests == limits인 Pod가 Guaranteed입니다.

</details>

<details>
<summary>힌트 3</summary>

```bash
kubectl -n cka-q021 create configmap qos-analysis \
  --from-literal=guaranteed=pod-guaranteed \
  --from-literal=burstable=pod-burstable \
  --from-literal=besteffort=pod-besteffort \
  --from-literal=first-terminated=pod-besteffort \
  --from-literal=eviction-order="BestEffort -> Burstable -> Guaranteed"
```

</details>
