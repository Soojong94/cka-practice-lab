# Problem 066: 정답 풀이

## Step 1: 노드 Cordon

```bash
NODE=$(kubectl -n cka-q066 get configmap drain-target -o jsonpath='{.data.node}')
kubectl cordon $NODE
```

## Step 2: Cordon 상태 확인 및 ConfigMap 생성

```bash
# SchedulingDisabled 확인
kubectl get nodes
# NAME             STATUS                     ROLES           AGE   VERSION
# <node>   Ready,SchedulingDisabled   <roles>   ...   ...

# ConfigMap 생성 (먼저 cordon 상태 기록)
kubectl -n cka-q066 create configmap drain-verify \
  --from-literal=node-cordoned="true" \
  --from-literal=node-uncordoned="false"
```

## Step 3: 노드 Drain

```bash
kubectl drain $NODE --delete-emptydir-data --ignore-daemonsets --force
```

## Step 4: Drain 후 상태 확인

```bash
# Pod 상태 확인 (Pending 또는 재생성 중)
kubectl -n cka-q066 get pods
```

## Step 5: 노드 Uncordon

```bash
kubectl uncordon $NODE

# Pod 재스케줄 대기
kubectl -n cka-q066 wait --for=condition=Ready pod -l app=web-app --timeout=60s
```

## Step 6: ConfigMap 업데이트

```bash
kubectl -n cka-q066 patch configmap drain-verify \
  --type merge -p '{"data":{"node-uncordoned":"true"}}'
```

## 검증

```bash
kubectl get nodes
kubectl -n cka-q066 get pods
kubectl -n cka-q066 get configmap drain-verify -o yaml
```
