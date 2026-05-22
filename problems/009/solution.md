# Problem 009: 정답 풀이

## Step 1: 기존 리소스 확인

```bash
kubectl -n cka-q009 get sa app-sa
kubectl -n cka-q009 get configmap app-config -o yaml
kubectl -n cka-q009 get secret app-secret -o yaml
```

## Step 2: projected 볼륨을 사용하는 Pod 생성

```bash
kubectl -n cka-q009 apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: projected-pod
spec:
  serviceAccountName: app-sa
  containers:
  - name: app
    image: busybox:1.36
    command: ["sleep", "3600"]
    volumeMounts:
    - name: projected-vol
      mountPath: /etc/projected
  volumes:
  - name: projected-vol
    projected:
      sources:
      - serviceAccountToken:
          path: token
          expirationSeconds: 3600
      - configMap:
          name: app-config
          items:
          - key: app.properties
            path: config/app.properties
      - secret:
          name: app-secret
          items:
          - key: api-key
            path: secrets/api-key
EOF
```

## Step 3: Pod 상태 확인

```bash
kubectl -n cka-q009 get pod projected-pod
# STATUS: Running
```

## Step 4: 마운트된 파일 확인

```bash
# 디렉토리 구조 확인
kubectl -n cka-q009 exec projected-pod -- find /etc/projected -type f

# ServiceAccount 토큰 확인
kubectl -n cka-q009 exec projected-pod -- cat /etc/projected/token

# ConfigMap 확인
kubectl -n cka-q009 exec projected-pod -- cat /etc/projected/config/app.properties
# 출력:
# app.name=projected-demo
# app.version=1.0.0
# app.env=production

# Secret 확인
kubectl -n cka-q009 exec projected-pod -- cat /etc/projected/secrets/api-key
# 출력: k8s-projected-secret-key-2024
```

## 검증

```bash
kubectl -n cka-q009 describe pod projected-pod | grep -A20 Volumes
```
