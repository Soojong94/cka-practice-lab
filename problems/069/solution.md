# Problem 069: 정답 풀이

## Step 1: namespaced 리소스 수 확인

```bash
NS_COUNT=$(kubectl api-resources --namespaced=true --no-headers | wc -l | tr -d ' ')
echo $NS_COUNT
```

## Step 2: deployments API 그룹 확인

```bash
kubectl api-resources | grep -w deployments
# deployments   deploy   apps/v1   true   Deployment
# API 그룹: apps
```

## Step 3: cronjobs namespaced 여부 확인

```bash
kubectl api-resources | grep -w cronjobs
# cronjobs   cj   batch/v1   true   CronJob
# NAMESPACED: true
```

## Step 4: nodes namespaced 여부 확인

```bash
kubectl api-resources | grep -w "^nodes "
# nodes   no   v1   false   Node
# NAMESPACED: false
```

## Step 5: ConfigMap 생성

```bash
kubectl -n cka-q069 create configmap api-info \
  --from-literal=namespaced-count="$NS_COUNT" \
  --from-literal=deployments-apigroup="apps" \
  --from-literal=cronjobs-namespaced="true" \
  --from-literal=nodes-namespaced="false"
```

## 검증

```bash
kubectl -n cka-q069 get configmap api-info -o yaml
```
