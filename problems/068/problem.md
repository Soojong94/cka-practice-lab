# Problem 068: Namespace 관리 및 리소스 격리

| 항목 | 값 |
|------|-----|
| 문제 번호 | 068 |
| 도메인 | Cluster Architecture, Installation & Configuration |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 10분 |
| 네임스페이스 | cka-q068 |

## Context

네임스페이스 `cka-q068-team-a`와 `cka-q068-team-b`가 생성되어 있습니다. 각 팀의 리소스 사용을 제한하기 위해 ResourceQuota와 LimitRange를 설정해야 합니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. 네임스페이스 `cka-q068-team-a`에 다음 스펙으로 ResourceQuota를 생성하세요:
   - 이름: `team-a-quota`
   - 최대 Pod 수: `5`
   - 최대 메모리 requests: `1Gi`
   - 최대 메모리 limits: `2Gi`

2. 네임스페이스 `cka-q068-team-b`에 다음 스펙으로 LimitRange를 생성하세요:
   - 이름: `team-b-limits`
   - 타입: Container
   - 기본 메모리 limit: `256Mi`
   - 기본 메모리 request: `128Mi`
   - 최대 메모리: `512Mi`

3. `cka-q068-team-b`에 LimitRange가 적용되는지 확인하기 위해 리소스 요청 없이 Pod `test-pod`를 생성하고, 자동으로 기본값이 적용되는지 확인하세요.

4. 네임스페이스 `cka-q068`에 ConfigMap `quota-verify`를 생성하고, `team-a-max-pods` 키에 `5`, `team-b-default-memory` 키에 `256Mi`를 저장하세요.

## Expected Outcome

- ResourceQuota `team-a-quota`가 `cka-q068-team-a`에 존재
- LimitRange `team-b-limits`가 `cka-q068-team-b`에 존재
- Pod `test-pod`에 기본 메모리 limit 256Mi 적용
- ConfigMap `quota-verify` 올바른 값 저장

<details>
<summary>힌트 1</summary>

ResourceQuota 생성:
```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: team-a-quota
  namespace: cka-q068-team-a
spec:
  hard:
    pods: "5"
    requests.memory: 1Gi
    limits.memory: 2Gi
```

</details>

<details>
<summary>힌트 2</summary>

LimitRange 생성:
```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: team-b-limits
  namespace: cka-q068-team-b
spec:
  limits:
  - type: Container
    default:
      memory: 256Mi
    defaultRequest:
      memory: 128Mi
    max:
      memory: 512Mi
```

</details>

<details>
<summary>힌트 3</summary>

LimitRange 적용 확인:
```bash
kubectl -n cka-q068-team-b run test-pod --image=nginx:alpine
kubectl -n cka-q068-team-b get pod test-pod -o jsonpath='{.spec.containers[0].resources}'
```

</details>
