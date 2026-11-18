# Problem 066: Node drain 및 cordon

| 항목 | 값 |
|------|-----|
| 문제 번호 | 066 |
| 도메인 | Cluster Architecture, Installation & Configuration |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 10분 |
| 네임스페이스 | cka-q066 |

## Context

네임스페이스 `cka-q066`에 Deployment `web-app` (replicas=2)과 standalone Pod `standalone-pod`가 실행 중입니다. 노드 유지보수를 위해 drain/cordon/uncordon 작업을 수행해야 합니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.
> 주의: Docker Desktop 단일 노드 클러스터에서는 drain 후 Pod가 같은 노드에 다시 스케줄됩니다.

## Tasks

1. 실습 대상 노드(ConfigMap `drain-target`의 `node` 값, Docker Desktop 기본은 `docker-desktop`)를 cordon하여 새로운 Pod가 스케줄되지 않도록 하세요.

2. 노드가 `SchedulingDisabled` 상태인지 확인하고, ConfigMap `drain-verify`의 `node-cordoned` 키에 `true`를 저장하세요.

3. 노드를 drain하세요. (옵션: `--delete-emptydir-data --ignore-daemonsets --force`)

4. drain 후 Deployment `web-app`의 Pod가 Pending 또는 재스케줄 상태인지 확인하세요.

5. 노드를 uncordon하여 다시 스케줄 가능하게 만들고, ConfigMap `drain-verify`의 `node-uncordoned` 키에 `true`를 저장하세요.

## Expected Outcome

- 최종적으로 노드가 uncordon 상태 (스케줄 가능)
- Deployment `web-app`의 Pod가 다시 Running 상태
- ConfigMap `drain-verify`에 올바른 값 저장

<details>
<summary>힌트 1</summary>

노드 cordon:
```bash
NODE=$(kubectl -n cka-q066 get configmap drain-target -o jsonpath='{.data.node}')
kubectl cordon $NODE
kubectl get nodes  # STATUS에 SchedulingDisabled 확인
```

</details>

<details>
<summary>힌트 2</summary>

노드 drain:
```bash
kubectl drain $NODE --delete-emptydir-data --ignore-daemonsets --force
```
단일 노드 클러스터에서는 drain 후 Pod가 Pending 상태가 됩니다.

</details>

<details>
<summary>힌트 3</summary>

노드 uncordon:
```bash
kubectl uncordon $NODE
# Pod가 다시 스케줄되어 Running 상태가 됩니다
kubectl -n cka-q066 wait --for=condition=Ready pod -l app=web-app --timeout=60s
```

</details>
