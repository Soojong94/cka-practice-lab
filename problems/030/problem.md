# Problem 030: scheduler 중지 후 수동 스케줄링

| 항목 | 값 |
|------|-----|
| 문제 번호 | 030 |
| 도메인 | Troubleshooting |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 8분 |
| 네임스페이스 | cka-q030 |

## Context

네임스페이스 `cka-q030`에 Pod `manual-schedule-pod`가 Pending 상태입니다. 이 Pod는 존재하지 않는 노드를 가리키는 `nodeSelector`가 설정되어 있어 스케줄링되지 않습니다. Pod를 수동으로 올바른 노드에 스케줄링하고, 추가로 정상적으로 스케줄링되는 Pod를 생성하세요.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. Pod `manual-schedule-pod`가 Pending인 이유를 확인하세요.
   - `kubectl -n cka-q030 describe pod manual-schedule-pod`

2. ConfigMap `cluster-info`에서 실제 노드 이름을 확인하세요.

3. Pod `manual-schedule-pod`를 수정하여 올바른 노드에서 실행되도록 하세요:
   - 잘못된 `nodeSelector`를 제거하고 올바른 `nodeName`을 지정하세요
   - Pod를 삭제하고 올바른 스펙으로 재생성해야 합니다

4. 추가로 `normal-pod`를 생성하세요:
   - 이미지: `nginx:alpine`
   - 특별한 스케줄링 제약 없이 (scheduler가 자동 배치)

5. 두 Pod가 모두 Running 상태인지 확인하세요.

## Expected Outcome

- Pod `manual-schedule-pod`가 Running 상태이며 올바른 노드에 배치됨
- Pod `normal-pod`가 Running 상태
- 두 Pod 모두 클러스터의 실제 노드에서 실행 중

<details>
<summary>힌트 1</summary>

Pending 원인 확인:
```bash
kubectl -n cka-q030 describe pod manual-schedule-pod
# Events에서 "node(s) didn't match Pod's node affinity/selector" 확인

kubectl -n cka-q030 get configmap cluster-info -o jsonpath='{.data.node-name}'
# 실제 노드 이름 확인
```

</details>

<details>
<summary>힌트 2</summary>

Pod의 nodeSelector는 변경할 수 없으므로 Pod를 삭제하고 재생성해야 합니다.
`nodeName`을 직접 지정하면 scheduler를 거치지 않고 특정 노드에 배치됩니다.

```yaml
spec:
  nodeName: <실제-노드-이름>
  containers:
  - name: nginx
    image: nginx:alpine
```

</details>

<details>
<summary>힌트 3</summary>

```bash
NODE_NAME=$(kubectl -n cka-q030 get configmap cluster-info -o jsonpath='{.data.node-name}')

# manual-schedule-pod 재생성
kubectl -n cka-q030 delete pod manual-schedule-pod --grace-period=0 --force
kubectl -n cka-q030 run manual-schedule-pod --image=nginx:alpine \
  --overrides="{\"spec\":{\"nodeName\":\"$NODE_NAME\"}}"

# normal-pod 생성
kubectl -n cka-q030 run normal-pod --image=nginx:alpine
```

</details>
