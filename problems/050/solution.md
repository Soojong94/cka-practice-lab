# Problem 050: 정답 풀이

## Step 1: important-pod 생성 (high-priority)

```bash
kubectl -n cka-q050 apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: important-pod
  namespace: cka-q050
spec:
  priorityClassName: high-priority
  containers:
  - name: nginx
    image: nginx:1-alpine
EOF
```

## Step 2: normal-pod 생성 (기본 우선순위)

```bash
kubectl -n cka-q050 apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: normal-pod
  namespace: cka-q050
spec:
  containers:
  - name: nginx
    image: nginx:1-alpine
EOF
```

## Step 3: 확인

```bash
# Pod priority 확인
kubectl -n cka-q050 get pod important-pod -o jsonpath='{.spec.priority}'
# 출력: 1000000

kubectl -n cka-q050 get pod normal-pod -o jsonpath='{.spec.priority}'
# 출력: 0

# PriorityClass 확인
kubectl get priorityclass high-priority
```

## 핵심 개념

- PriorityClass: 클러스터 범위 리소스로 Pod 우선순위를 정의
- value: 정수값 (높을수록 우선순위 높음)
- globalDefault: true로 설정하면 모든 Pod의 기본 PriorityClass가 됨
- Preemption: 높은 우선순위 Pod가 스케줄되지 못할 때 낮은 우선순위 Pod를 축출
- preemptionPolicy: Never로 설정하면 preemption 비활성화
