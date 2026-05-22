# Problem 032: 정답 풀이

## Step 1: Pod 상태 확인

```bash
kubectl -n cka-q032 get pod memory-hog
kubectl -n cka-q032 describe pod memory-hog
```

`Last State`에서 `Reason: OOMKilled`를 확인합니다.

## Step 2: 현재 메모리 limit 확인

```bash
kubectl -n cka-q032 get pod memory-hog -o jsonpath='{.spec.containers[0].resources.limits.memory}'
# 10Mi
```

## Step 3: Pod 삭제 후 재생성

```bash
# 기존 Pod 삭제
kubectl -n cka-q032 delete pod memory-hog --grace-period=0 --force

# 새 Pod 생성 (메모리 limit 증가)
kubectl -n cka-q032 apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: memory-hog
  namespace: cka-q032
  labels:
    app: memory-hog
spec:
  containers:
  - name: stress
    image: polinux/stress:latest
    command: ["stress"]
    args: ["--vm", "1", "--vm-bytes", "50M", "--vm-hang", "1"]
    resources:
      requests:
        memory: "64Mi"
      limits:
        memory: "128Mi"
EOF
```

## Step 4: 정상 동작 확인

```bash
kubectl -n cka-q032 get pod memory-hog
# STATUS가 Running인지 확인

kubectl -n cka-q032 describe pod memory-hog | grep -A5 "State:"
# State: Running 확인
```

## 검증

```bash
kubectl -n cka-q032 get pod memory-hog -o jsonpath='{.spec.containers[0].resources.limits.memory}'
# 128Mi
```
