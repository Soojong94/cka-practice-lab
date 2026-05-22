# Problem 013: 정답 풀이

## Step 1: Pending 원인 분석

```bash
kubectl -n cka-q013 get pods
kubectl -n cka-q013 describe pod memory-hog
kubectl -n cka-q013 describe pod node-selector-pod
```

- `memory-hog`: `Insufficient memory` - 100Gi 메모리 요청은 노드 용량 초과
- `node-selector-pod`: `node(s) didn't match Pod's node affinity/selector` - `disktype: superfast-nvme` 라벨을 가진 노드 없음

## Step 2: memory-hog Pod 수정

```bash
kubectl -n cka-q013 delete pod memory-hog --grace-period=0 --force

kubectl -n cka-q013 apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: memory-hog
  labels:
    app: memory-hog
spec:
  containers:
  - name: busybox
    image: busybox:1.36
    command: ["sleep", "3600"]
    resources:
      requests:
        memory: "64Mi"
EOF
```

## Step 3: node-selector-pod Pod 수정

```bash
kubectl -n cka-q013 delete pod node-selector-pod --grace-period=0 --force

kubectl -n cka-q013 apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: node-selector-pod
  labels:
    app: node-selector-pod
spec:
  containers:
  - name: busybox
    image: busybox:1.36
    command: ["sleep", "3600"]
    resources:
      requests:
        memory: "64Mi"
EOF
```

## 검증

```bash
kubectl -n cka-q013 get pods
# 두 Pod 모두 Running 상태인지 확인
```
