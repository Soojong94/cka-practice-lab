# Problem 068: 정답 풀이

## Step 1: ResourceQuota 생성

```bash
kubectl -n cka-q068-team-a apply -f - <<EOF
apiVersion: v1
kind: ResourceQuota
metadata:
  name: team-a-quota
  namespace: cka-q068-team-a
spec:
  hard:
    pods: "5"
    requests.memory: 1Gi
    limits.memory: 2Gi
EOF
```

## Step 2: LimitRange 생성

```bash
kubectl -n cka-q068-team-b apply -f - <<EOF
apiVersion: v1
kind: LimitRange
metadata:
  name: team-b-limits
  namespace: cka-q068-team-b
spec:
  limits:
  - type: Container
    default:
      memory: 256Mi
    defaultRequest:
      memory: 128Mi
    max:
      memory: 512Mi
EOF
```

## Step 3: LimitRange 적용 확인

```bash
# 리소스 요청 없이 Pod 생성
kubectl -n cka-q068-team-b run test-pod --image=nginx:alpine

# 기본값 적용 확인
kubectl -n cka-q068-team-b get pod test-pod -o jsonpath='{.spec.containers[0].resources}'
# 출력: {"limits":{"memory":"256Mi"},"requests":{"memory":"128Mi"}}
```

## Step 4: ConfigMap 생성

```bash
kubectl -n cka-q068 create configmap quota-verify \
  --from-literal=team-a-max-pods="5" \
  --from-literal=team-b-default-memory="256Mi"
```

## 검증

```bash
kubectl -n cka-q068-team-a describe resourcequota team-a-quota
kubectl -n cka-q068-team-b describe limitrange team-b-limits
kubectl -n cka-q068 get configmap quota-verify -o yaml
```
