# Problem 042: 정답 풀이

## Step 1: Deployment 생성 (Pod Anti-Affinity 포함)

```bash
kubectl -n cka-q042 apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: spread-app
  namespace: cka-q042
spec:
  replicas: 3
  selector:
    matchLabels:
      app: spread-app
  template:
    metadata:
      labels:
        app: spread-app
    spec:
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchLabels:
                  app: spread-app
              topologyKey: kubernetes.io/hostname
      containers:
      - name: nginx
        image: nginx:1-alpine
EOF
```

## Step 2: 확인

```bash
# Deployment 상태 확인
kubectl -n cka-q042 get deployment spread-app

# Pod 분산 확인
kubectl -n cka-q042 get pods -o wide

# Anti-Affinity 설정 확인
kubectl -n cka-q042 get deployment spread-app -o jsonpath='{.spec.template.spec.affinity}' | jq .
```

## 핵심 개념

- `preferredDuringSchedulingIgnoredDuringExecution`: 소프트 규칙 (가능하면 분산, 불가능하면 같은 노드에도 배치)
- `requiredDuringSchedulingIgnoredDuringExecution`: 하드 규칙 (반드시 분산, 불가능하면 Pending)
- 단일 노드 환경에서는 반드시 `preferred`를 사용해야 모든 Pod가 스케줄됨
- `topologyKey: kubernetes.io/hostname`은 노드 단위 분산을 의미
