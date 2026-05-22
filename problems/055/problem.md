# Problem 055: Resource Quota와 LimitRange

| 항목 | 값 |
|------|-----|
| 문제 번호 | 055 |
| 도메인 | Workloads & Scheduling |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 12분 |
| 네임스페이스 | cka-q055 |

## Context

네임스페이스 `cka-q055`에 리소스 사용량을 제한해야 합니다. ResourceQuota로 네임스페이스 전체 리소스를 제한하고, LimitRange로 개별 컨테이너의 기본 리소스를 설정하세요.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. 네임스페이스 `cka-q055`에 ResourceQuota를 생성하세요:
   - 이름: `ns-quota`
   - 최대 Pod 수: `4`
   - 최대 메모리: `2Gi`
   - 최대 CPU: `2`

2. 네임스페이스 `cka-q055`에 LimitRange를 생성하세요:
   - 이름: `ns-limitrange`
   - 기본 컨테이너 limits: memory=`256Mi`, cpu=`250m`
   - 기본 컨테이너 requests: memory=`128Mi`, cpu=`100m`

3. Deployment를 생성하세요:
   - 이름: `quota-test`
   - 이미지: `nginx:1-alpine`
   - 레플리카: `3`
   - (LimitRange에 의해 자동으로 리소스가 설정됨)

4. 3개의 Pod가 정상적으로 Running인지 확인하세요 (quota 내에서 동작).

## Expected Outcome

- ResourceQuota `ns-quota` 존재 (pods=4, memory=2Gi, cpu=2)
- LimitRange `ns-limitrange` 존재 (기본 limits/requests 설정)
- Deployment `quota-test`의 3개 Pod가 Running 상태
- 4번째 Pod 생성 시 quota 초과로 실패

<details>
<summary>힌트 1</summary>

ResourceQuota 생성:
```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: ns-quota
spec:
  hard:
    pods: "4"
    requests.memory: "2Gi"
    requests.cpu: "2"
    limits.memory: "2Gi"
    limits.cpu: "2"
```

</details>

<details>
<summary>힌트 2</summary>

LimitRange 생성:
```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: ns-limitrange
spec:
  limits:
  - default:
      memory: "256Mi"
      cpu: "250m"
    defaultRequest:
      memory: "128Mi"
      cpu: "100m"
    type: Container
```

</details>

<details>
<summary>힌트 3</summary>

ResourceQuota가 있는 네임스페이스에서 Pod를 생성하려면 리소스 요청/제한이 반드시 설정되어야 합니다. LimitRange가 있으면 자동으로 기본값이 적용됩니다.

```bash
kubectl -n cka-q055 describe resourcequota ns-quota
kubectl -n cka-q055 describe limitrange ns-limitrange
```

</details>
