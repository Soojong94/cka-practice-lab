# Problem 039: 정답 풀이

## Step 1: 토큰 파일 확인

```bash
kubectl -n cka-q039 exec api-pod -- ls /var/run/secrets/kubernetes.io/serviceaccount/
# 파일이 없거나 디렉토리가 없음
```

## Step 2: ServiceAccount 설정 확인

```bash
kubectl -n cka-q039 get sa api-sa -o yaml
# automountServiceAccountToken: false
```

## Step 3: Pod 삭제 후 재생성

```bash
# 기존 Pod 삭제
kubectl -n cka-q039 delete pod api-pod --grace-period=0 --force

# automountServiceAccountToken: true를 Pod spec에 추가하여 재생성
kubectl -n cka-q039 apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: api-pod
  namespace: cka-q039
  labels:
    app: api-pod
spec:
  serviceAccountName: api-sa
  automountServiceAccountToken: true
  containers:
  - name: kubectl
    image: bitnami/kubectl:latest
    command: ["sleep", "3600"]
EOF
```

## Step 4: 토큰 마운트 확인

```bash
kubectl -n cka-q039 wait --for=condition=Ready pod/api-pod --timeout=60s
kubectl -n cka-q039 exec api-pod -- ls /var/run/secrets/kubernetes.io/serviceaccount/
# ca.crt  namespace  token
```

## 검증

```bash
kubectl -n cka-q039 exec api-pod -- cat /var/run/secrets/kubernetes.io/serviceaccount/token
# JWT 토큰이 출력됨
```
