# Problem 059: 정답 풀이

## Step 1: ServiceAccount 생성

```bash
kubectl -n cka-q059 create serviceaccount app-sa
```

## Step 2: Pod 생성 (ServiceAccount 지정)

```bash
kubectl -n cka-q059 apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  serviceAccountName: app-sa
  containers:
  - name: nginx
    image: nginx:alpine
EOF
```

## Step 3: Pod Ready 대기

```bash
kubectl -n cka-q059 wait --for=condition=Ready pod/app-pod --timeout=60s
```

## Step 4: 토큰 확인 및 ConfigMap 생성

```bash
# 토큰 파일 존재 확인
if kubectl -n cka-q059 exec app-pod -- ls /var/run/secrets/kubernetes.io/serviceaccount/token &>/dev/null; then
  TOKEN_STATUS="exists"
else
  TOKEN_STATUS="not-found"
fi

# ConfigMap 생성
kubectl -n cka-q059 create configmap sa-verify \
  --from-literal=token-status="$TOKEN_STATUS"
```

## 검증

```bash
kubectl -n cka-q059 get serviceaccount app-sa
kubectl -n cka-q059 get pod app-pod -o jsonpath='{.spec.serviceAccountName}'
kubectl -n cka-q059 exec app-pod -- cat /var/run/secrets/kubernetes.io/serviceaccount/token | head -c 50
```
