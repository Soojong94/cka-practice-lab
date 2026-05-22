# Problem 038: 정답 풀이

## Step 1: Pod 상태 확인

```bash
kubectl -n cka-q038 get pod ssd-pod
# STATUS: Pending

kubectl -n cka-q038 describe pod ssd-pod
# Events: "0/1 nodes are available: 1 node(s) didn't match Pod's node affinity/selector, 1 node(s) had untolerated taint"
```

## Step 2: 노드에 레이블 추가

```bash
NODE_NAME=$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')
kubectl label nodes $NODE_NAME disk=ssd
```

## Step 3: Pod 삭제 후 toleration 추가하여 재생성

```bash
# 기존 Pod 삭제
kubectl -n cka-q038 delete pod ssd-pod --grace-period=0 --force

# toleration 추가한 새 Pod 생성
kubectl -n cka-q038 apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: ssd-pod
  namespace: cka-q038
  labels:
    app: ssd-pod
spec:
  nodeSelector:
    disk: ssd
  tolerations:
  - key: "dedicated"
    operator: "Equal"
    value: "special"
    effect: "NoSchedule"
  containers:
  - name: nginx
    image: nginx:1.24-alpine
    ports:
    - containerPort: 80
EOF
```

## Step 4: 확인

```bash
kubectl -n cka-q038 get pod ssd-pod
# STATUS: Running

kubectl get nodes --show-labels | grep disk
# disk=ssd 확인
```

## 검증

```bash
kubectl -n cka-q038 get pod ssd-pod -o jsonpath='{.status.phase}'
# Running
```
