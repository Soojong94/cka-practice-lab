# Problem 065: 정답 풀이

## Step 1: CRD 존재 확인

```bash
kubectl get crd apps.operator.example.com &>/dev/null && CRD_EXISTS="true" || CRD_EXISTS="false"
echo $CRD_EXISTS  # true
```

## Step 2: Custom Resource 생성

```bash
kubectl -n cka-q065 apply -f - <<EOF
apiVersion: operator.example.com/v1
kind: App
metadata:
  name: my-app
  namespace: cka-q065
spec:
  appName: web-frontend
  replicas: 2
  image: nginx:alpine
EOF
```

## Step 3: 컨트롤러 상태 확인

```bash
# 컨트롤러 Running 확인
AVAILABLE=$(kubectl -n cka-q065 get deployment app-controller -o jsonpath='{.status.availableReplicas}' 2>/dev/null)
if [ "$AVAILABLE" -ge 1 ] 2>/dev/null; then
  CTRL_RUNNING="true"
else
  CTRL_RUNNING="false"
fi
```

## Step 4: 컨트롤러 로그에서 CR 감지 확인

```bash
# CR 생성 후 잠시 대기 (컨트롤러가 감지할 시간)
sleep 10

# 로그 확인
if kubectl -n cka-q065 logs deployment/app-controller | grep -q "my-app"; then
  CR_DETECTED="true"
else
  CR_DETECTED="false"
fi
```

## Step 5: ConfigMap 생성

```bash
kubectl -n cka-q065 create configmap operator-verify \
  --from-literal=crd-exists="$CRD_EXISTS" \
  --from-literal=controller-running="$CTRL_RUNNING" \
  --from-literal=cr-detected="$CR_DETECTED"
```

## 검증

```bash
kubectl -n cka-q065 get configmap operator-verify -o yaml
kubectl -n cka-q065 get apps.operator.example.com
```
