# Problem 001: 정답 풀이

## Step 1: PersistentVolume 생성

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: safari-pv
spec:
  capacity:
    storage: 2Gi
  accessModes:
    - ReadWriteOnce
  storageClassName: ""
  hostPath:
    path: /Volumes/Data
EOF
```

## Step 2: PersistentVolumeClaim 생성

```bash
kubectl -n cka-q001 apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: safari-pvc
  namespace: cka-q001
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: ""
  resources:
    requests:
      storage: 2Gi
EOF
```

## Step 3: PVC Bound 확인

```bash
kubectl -n cka-q001 get pvc safari-pvc
# STATUS가 Bound인지 확인
```

## Step 4: Deployment에 Volume Mount 추가

```bash
kubectl -n cka-q001 patch deployment safari --type='json' -p='[
  {"op": "add", "path": "/spec/template/spec/volumes", "value": [{"name": "safari-data", "persistentVolumeClaim": {"claimName": "safari-pvc"}}]},
  {"op": "add", "path": "/spec/template/spec/containers/0/volumeMounts", "value": [{"name": "safari-data", "mountPath": "/tmp/safari-data"}]}
]'
```

또는 `kubectl -n cka-q001 edit deployment safari`로 직접 편집:

```yaml
spec:
  template:
    spec:
      volumes:
      - name: safari-data
        persistentVolumeClaim:
          claimName: safari-pvc
      containers:
      - name: httpd
        # ... 기존 설정 ...
        volumeMounts:
        - name: safari-data
          mountPath: /tmp/safari-data
```

## 검증

```bash
kubectl get pv safari-pv
kubectl -n cka-q001 get pvc safari-pvc
kubectl -n cka-q001 describe pod -l app=safari | grep -A2 Mounts
```
