# Problem 051: 정답 풀이

## Step 1: Deployment 생성 (topologySpreadConstraints 포함)

```bash
kubectl -n cka-q051 apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: balanced-app
  namespace: cka-q051
spec:
  replicas: 3
  selector:
    matchLabels:
      app: balanced-app
  template:
    metadata:
      labels:
        app: balanced-app
    spec:
      topologySpreadConstraints:
      - maxSkew: 1
        topologyKey: topology.kubernetes.io/zone
        whenUnsatisfiable: ScheduleAnyway
        labelSelector:
          matchLabels:
            app: balanced-app
      containers:
      - name: nginx
        image: nginx:1-alpine
EOF
```

## Step 2: 확인

```bash
# Deployment 상태 확인
kubectl -n cka-q051 get deployment balanced-app

# topologySpreadConstraints 확인
kubectl -n cka-q051 get deployment balanced-app -o jsonpath='{.spec.template.spec.topologySpreadConstraints}' | jq .

# Pod 분산 확인
kubectl -n cka-q051 get pods -o wide
```

## 핵심 개념

- topologySpreadConstraints: Pod를 토폴로지 도메인 간에 균등하게 분산
- maxSkew: 도메인 간 Pod 수 차이의 최대 허용값
- topologyKey: 분산 기준이 되는 노드 레이블 키
- whenUnsatisfiable: DoNotSchedule(하드) 또는 ScheduleAnyway(소프트)
- Pod Anti-Affinity와 달리 여러 도메인에 걸쳐 균등 분산을 보장
- 멀티 존 클러스터에서 고가용성을 위해 주로 사용
