# Problem 067: 정답 풀이

## Step 1: 생성 시간 기준 정렬

```bash
SORTED_PODS=$(kubectl -n cka-q067 get pods --sort-by=.metadata.creationTimestamp \
  -o jsonpath='{.items[*].metadata.name}' | tr ' ' ',')
echo $SORTED_PODS
# 출력: pod-alpha,pod-beta,pod-gamma,pod-delta
```

## Step 2: custom-columns 명령 작성

```bash
CUSTOM_CMD="kubectl -n cka-q067 get pods -o custom-columns=NAME:.metadata.name,IP:.status.podIP"
```

## Step 3: jsonpath로 레이블 추출

```bash
POD_BETA_TIER=$(kubectl -n cka-q067 get pod pod-beta -o jsonpath='{.metadata.labels.tier}')
echo $POD_BETA_TIER
# 출력: backend
```

## Step 4: 레이블 셀렉터로 Pod 수 확인

```bash
BACKEND_COUNT=$(kubectl -n cka-q067 get pods -l tier=backend --no-headers | wc -l | tr -d ' ')
echo $BACKEND_COUNT
# 출력: 2
```

## Step 5: ConfigMap 생성

```bash
kubectl -n cka-q067 create configmap kubectl-output \
  --from-literal=sorted-pods="$SORTED_PODS" \
  --from-literal=custom-columns-cmd="$CUSTOM_CMD" \
  --from-literal=pod-beta-tier="$POD_BETA_TIER" \
  --from-literal=backend-count="$BACKEND_COUNT"
```

## 검증

```bash
kubectl -n cka-q067 get configmap kubectl-output -o yaml
```
