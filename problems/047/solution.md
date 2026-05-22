# Problem 047: 정답 풀이

## Step 1: Deployment 리소스 요청 확인

```bash
kubectl -n cka-q047 get deployment hpa-target -o jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu}'
# 출력: 100m
```

## Step 2: HPA 생성

```bash
kubectl -n cka-q047 autoscale deployment hpa-target --min=2 --max=5 --cpu-percent=50
```

또는 YAML로:

```bash
kubectl -n cka-q047 apply -f - <<EOF
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: hpa-target
  namespace: cka-q047
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: hpa-target
  minReplicas: 2
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
EOF
```

## Step 3: 확인

```bash
# HPA 상태 확인
kubectl -n cka-q047 get hpa hpa-target

# Deployment replicas 확인 (최소 2로 스케일됨)
kubectl -n cka-q047 get deployment hpa-target
```

## 핵심 개념

- HPA는 메트릭 기반으로 Deployment/ReplicaSet의 replicas를 자동 조정
- `resources.requests.cpu`가 설정되어 있어야 CPU 기반 HPA가 동작
- metrics-server가 클러스터에 설치되어 있어야 함
- minReplicas보다 현재 replicas가 적으면 즉시 스케일 업
- `autoscaling/v2` API를 사용하면 여러 메트릭을 동시에 설정 가능
