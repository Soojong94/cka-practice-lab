# Problem 030: 정답 풀이

## Step 1: Pending 원인 확인

```bash
kubectl -n cka-q030 get pods
# manual-schedule-pod: Pending

kubectl -n cka-q030 describe pod manual-schedule-pod
# Events: 0/1 nodes are available: 1 node(s) didn't match Pod's node affinity/selector
# nodeSelector: kubernetes.io/hostname=nonexistent-node-xyz
```

## Step 2: 실제 노드 이름 확인

```bash
kubectl -n cka-q030 get configmap cluster-info -o jsonpath='{.data.node-name}'
# 예: docker-desktop (멀티 노드 클러스터면 워커 노드 이름)
```

## Step 3: manual-schedule-pod 재생성

```bash
NODE_NAME=$(kubectl -n cka-q030 get configmap cluster-info -o jsonpath='{.data.node-name}')

# 기존 Pod 삭제
kubectl -n cka-q030 delete pod manual-schedule-pod --grace-period=0 --force

# nodeName을 지정하여 재생성
kubectl -n cka-q030 apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: manual-schedule-pod
  labels:
    app: manual-schedule
spec:
  nodeName: $NODE_NAME
  containers:
  - name: nginx
    image: nginx:alpine
EOF
```

또는 `kubectl run`으로:

```bash
kubectl -n cka-q030 run manual-schedule-pod --image=nginx:alpine \
  --overrides="{\"spec\":{\"nodeName\":\"$NODE_NAME\"}}"
```

## Step 4: normal-pod 생성

```bash
kubectl -n cka-q030 run normal-pod --image=nginx:alpine
```

## Step 5: 확인

```bash
kubectl -n cka-q030 get pods -o wide
# 두 Pod 모두 Running, NODE 컬럼에 올바른 노드 이름 표시
```

## 참고: 수동 스케줄링 vs 자동 스케줄링

- **nodeName**: scheduler를 완전히 우회하여 특정 노드에 직접 배치
- **nodeSelector**: scheduler가 조건에 맞는 노드를 선택
- **nodeAffinity**: 더 유연한 노드 선택 규칙 (preferred/required)

scheduler가 중지된 상태에서는 `nodeName`을 직접 지정해야 Pod가 스케줄링됩니다.
