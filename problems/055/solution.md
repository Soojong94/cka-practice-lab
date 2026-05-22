# Problem 055: 정답 풀이

## Step 1: ResourceQuota 생성

```bash
kubectl -n cka-q055 apply -f - <<EOF
apiVersion: v1
kind: ResourceQuota
metadata:
  name: ns-quota
  namespace: cka-q055
spec:
  hard:
    pods: "4"
    requests.memory: "2Gi"
    requests.cpu: "2"
    limits.memory: "2Gi"
    limits.cpu: "2"
EOF
```

## Step 2: LimitRange 생성

```bash
kubectl -n cka-q055 apply -f - <<EOF
apiVersion: v1
kind: LimitRange
metadata:
  name: ns-limitrange
  namespace: cka-q055
spec:
  limits:
  - default:
      memory: "256Mi"
      cpu: "250m"
    defaultRequest:
      memory: "128Mi"
      cpu: "100m"
    type: Container
EOF
```

## Step 3: Deployment 생성

```bash
kubectl -n cka-q055 apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: quota-test
  namespace: cka-q055
spec:
  replicas: 3
  selector:
    matchLabels:
      app: quota-test
  template:
    metadata:
      labels:
        app: quota-test
    spec:
      containers:
      - name: nginx
        image: nginx:1-alpine
EOF
```

## Step 4: 확인

```bash
# ResourceQuota 사용량 확인
kubectl -n cka-q055 describe resourcequota ns-quota

# LimitRange 확인
kubectl -n cka-q055 describe limitrange ns-limitrange

# Deployment 상태 확인
kubectl -n cka-q055 get deployment quota-test

# Pod에 자동 적용된 리소스 확인
kubectl -n cka-q055 get pod -l app=quota-test -o jsonpath='{.items[0].spec.containers[0].resources}'
```

## Step 5: Quota 초과 테스트 (선택)

```bash
# 4번째 Pod 생성 시도 (quota 내)
kubectl -n cka-q055 run extra-pod --image=nginx:1-alpine
# 성공 (총 4개 Pod)

# 5번째 Pod 생성 시도 (quota 초과)
kubectl -n cka-q055 run extra-pod2 --image=nginx:1-alpine
# 실패: exceeded quota
```

## 핵심 개념

- ResourceQuota: 네임스페이스 전체의 리소스 사용량 제한
- LimitRange: 개별 컨테이너/Pod의 기본 리소스 설정 및 최소/최대 제한
- ResourceQuota가 있으면 Pod에 반드시 리소스 요청/제한이 필요
- LimitRange의 default/defaultRequest가 있으면 자동으로 적용됨
- Quota 초과 시 새 Pod 생성이 거부됨 (Deployment의 경우 ReplicaSet 이벤트에서 확인)
