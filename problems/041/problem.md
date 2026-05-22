# Problem 041: DaemonSet 생성 (모든 노드 포함)

| 항목 | 값 |
|------|-----|
| 문제 번호 | 041 |
| 도메인 | Workloads & Scheduling |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 8분 |
| 네임스페이스 | cka-q041 |

## Context

네임스페이스 `cka-q041`에 모든 노드에서 실행되어야 하는 중요한 모니터링 에이전트를 배포해야 합니다. Control Plane 노드를 포함한 모든 노드에서 반드시 실행되어야 합니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. 네임스페이스 `cka-q041`에 다음 스펙으로 DaemonSet을 생성하세요:
   - 이름: `ds-important`
   - 이미지: `httpd:2-alpine`
   - 레이블 (Pod template): `id=ds-important`

2. 리소스 요청(requests)을 설정하세요:
   - CPU: `10m`
   - Memory: `10Mi`

3. Control Plane 노드에서도 실행되도록 toleration을 추가하세요:
   - key: `node-role.kubernetes.io/control-plane`
   - effect: `NoSchedule`
   - operator: `Exists`

4. DaemonSet의 Pod가 클러스터의 모든 노드에서 Running 상태인지 확인하세요.

## Expected Outcome

- `kubectl -n cka-q041 get ds ds-important` 실행 시 DESIRED와 CURRENT가 동일
- 모든 노드에서 Pod가 Running 상태
- Pod에 올바른 toleration과 리소스 요청이 설정됨

<details>
<summary>힌트 1</summary>

DaemonSet은 클러스터의 모든(또는 일부) 노드에 Pod를 하나씩 배포합니다. `spec.template.spec.tolerations`를 사용하여 taint가 있는 노드에서도 실행할 수 있습니다.

</details>

<details>
<summary>힌트 2</summary>

Control Plane 노드에는 보통 `node-role.kubernetes.io/control-plane:NoSchedule` taint가 있습니다. 이를 tolerate하려면:

```yaml
tolerations:
- key: node-role.kubernetes.io/control-plane
  operator: Exists
  effect: NoSchedule
```

</details>

<details>
<summary>힌트 3</summary>

리소스 요청은 `spec.template.spec.containers[].resources.requests`에 설정합니다:

```yaml
resources:
  requests:
    cpu: "10m"
    memory: "10Mi"
```

</details>
