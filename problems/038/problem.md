# Problem 038: Node 레이블/taint 불일치 해결

| 항목 | 값 |
|------|-----|
| 문제 번호 | 038 |
| 도메인 | Troubleshooting |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 8분 |
| 네임스페이스 | cka-q038 |

## Context

네임스페이스 `cka-q038`에 `ssd-pod`이 배포되었으나 `Pending` 상태입니다. 이 Pod는 `nodeSelector: disk=ssd`를 사용하지만, 노드에 해당 레이블이 없습니다. 또한 노드에 `dedicated=special:NoSchedule` taint가 설정되어 있어 toleration도 필요합니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. Pod `ssd-pod`가 Pending인 원인을 분석하세요.
   - `kubectl describe pod`로 Events 확인

2. 노드에 `disk=ssd` 레이블을 추가하세요.
   - `kubectl label nodes <node-name> disk=ssd`

3. Pod를 삭제하고, toleration을 추가한 새 Pod를 생성하세요:
   - nodeSelector: `disk: ssd`
   - toleration: `dedicated=special:NoSchedule`

4. Pod가 `Running` 상태가 되는지 확인하세요.

## Expected Outcome

- 노드에 `disk=ssd` 레이블이 존재
- Pod `ssd-pod`가 `Running` 상태
- Pod에 `dedicated=special:NoSchedule` toleration이 설정됨

<details>
<summary>힌트 1</summary>

`kubectl -n cka-q038 describe pod ssd-pod`의 Events에서 "0/1 nodes are available" 메시지를 확인합니다. nodeSelector와 taint 두 가지 문제가 있습니다.

</details>

<details>
<summary>힌트 2</summary>

노드 레이블 추가:
```bash
kubectl get nodes   # 노드 이름 확인 (Docker Desktop: docker-desktop)
kubectl label nodes <node-name> disk=ssd
```

</details>

<details>
<summary>힌트 3</summary>

Pod에 toleration 추가:
```yaml
spec:
  tolerations:
  - key: "dedicated"
    operator: "Equal"
    value: "special"
    effect: "NoSchedule"
  nodeSelector:
    disk: ssd
```

</details>
