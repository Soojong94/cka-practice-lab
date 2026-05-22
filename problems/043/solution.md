# Problem 043: 정답 풀이

## Step 1: gpu-pod 생성 (gpu=true 노드에 스케줄)

```bash
kubectl -n cka-q043 apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: gpu-pod
  namespace: cka-q043
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: gpu
            operator: In
            values:
            - "true"
  containers:
  - name: nginx
    image: nginx:1-alpine
EOF
```

## Step 2: cpu-pod 생성 (gpu=false 노드에 스케줄 - Pending 예상)

```bash
kubectl -n cka-q043 apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: cpu-pod
  namespace: cka-q043
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: gpu
            operator: In
            values:
            - "false"
  containers:
  - name: nginx
    image: nginx:1-alpine
EOF
```

## Step 3: 확인

```bash
# Pod 상태 확인
kubectl -n cka-q043 get pods

# gpu-pod는 Running, cpu-pod는 Pending이어야 함
kubectl -n cka-q043 get pod gpu-pod -o wide
kubectl -n cka-q043 describe pod cpu-pod | grep -A5 Events
```

## 핵심 개념

- `requiredDuringSchedulingIgnoredDuringExecution`: 하드 규칙 (반드시 조건 충족 필요)
- `preferredDuringSchedulingIgnoredDuringExecution`: 소프트 규칙 (가능하면 조건 충족)
- matchExpressions의 operator: In, NotIn, Exists, DoesNotExist, Gt, Lt
- 조건을 만족하는 노드가 없으면 Pod는 Pending 상태로 유지됨
