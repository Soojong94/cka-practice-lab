# Problem 010: 정답 풀이

## Step 1: 현재 상태 분석

```bash
# PV 스펙 확인
kubectl get pv debug-pv -o yaml
# storageClassName: manual
# accessModes: [ReadWriteOnce]
# capacity: 2Gi

# PVC 스펙 확인
kubectl -n cka-q010 get pvc debug-pvc -o yaml
# storageClassName: wrong-class  ← 문제 1: PV와 불일치
# accessModes: [ReadWriteMany]   ← 문제 2: PV와 불일치

# PVC 상태 확인
kubectl -n cka-q010 get pvc debug-pvc
# STATUS: Pending
```

## Step 2: 문제 원인 파악

1. **storageClassName 불일치**: PV는 `manual`, PVC는 `wrong-class`
2. **accessModes 불일치**: PV는 `ReadWriteOnce`, PVC는 `ReadWriteMany`

## Step 3: PVC 삭제 후 올바른 스펙으로 재생성

PVC의 `storageClassName`과 `accessModes`는 immutable 필드이므로 삭제 후 재생성해야 합니다.

```bash
# 기존 PVC 삭제
kubectl -n cka-q010 delete pvc debug-pvc

# 올바른 스펙으로 PVC 재생성
kubectl -n cka-q010 apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: debug-pvc
  namespace: cka-q010
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: manual
  resources:
    requests:
      storage: 2Gi
EOF
```

## Step 4: 바인딩 확인

```bash
kubectl -n cka-q010 get pvc debug-pvc
# NAME        STATUS   VOLUME     CAPACITY   ACCESS MODES   STORAGECLASS
# debug-pvc   Bound    debug-pv   2Gi        RWO            manual

kubectl get pv debug-pv
# NAME       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM
# debug-pv   2Gi        RWO            Retain           Bound    cka-q010/debug-pvc
```

## 검증

```bash
kubectl -n cka-q010 get pvc debug-pvc -o jsonpath='{.status.phase}'
# 출력: Bound
```
