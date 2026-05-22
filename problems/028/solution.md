# Problem 028: 정답 풀이

## Step 1: 문제 진단

```bash
kubectl -n cka-q028 get pvc data-pvc
# STATUS: Pending

kubectl -n cka-q028 describe pvc data-pvc
# Events에서 "storageclass.storage.k8s.io "fast-ssd" not found" 확인

kubectl get storageclass
# fast-ssd StorageClass가 없음
```

## 방법 1: StorageClass 생성 (Docker Desktop hostpath provisioner 사용)

```bash
kubectl apply -f - <<EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-ssd
provisioner: docker.io/hostpath
volumeBindingMode: Immediate
EOF
```

## 방법 2: PVC를 기존 StorageClass로 변경

Docker Desktop에는 기본 `hostpath` StorageClass가 있습니다.

```bash
# 기존 PVC 삭제
kubectl -n cka-q028 delete pvc data-pvc

# 올바른 StorageClass로 재생성
kubectl -n cka-q028 apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: hostpath
  resources:
    requests:
      storage: 1Gi
EOF
```

## 방법 3: 수동 PV 생성 후 바인딩

```bash
# PV 생성
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: data-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  storageClassName: fast-ssd
  hostPath:
    path: /tmp/data-pv
EOF
```

## 검증

```bash
kubectl -n cka-q028 get pvc data-pvc
# STATUS: Bound
```
