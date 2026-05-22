# Problem 004: 정답 풀이

## Step 1: StorageClass 확인

```bash
kubectl get storageclass expandable-sc -o yaml
# allowVolumeExpansion: true 확인
```

## Step 2: 현재 PVC 용량 확인

```bash
kubectl -n cka-q004 get pvc data-pvc
# CAPACITY가 1Gi인지 확인
```

## Step 3: PVC 용량 확장 (1Gi → 2Gi)

```bash
kubectl -n cka-q004 patch pvc data-pvc -p '{"spec":{"resources":{"requests":{"storage":"2Gi"}}}}'
```

또는 `kubectl -n cka-q004 edit pvc data-pvc`로 직접 편집:

```yaml
spec:
  resources:
    requests:
      storage: 2Gi  # 1Gi에서 2Gi로 변경
```

## Step 4: 확장 결과 확인

```bash
# PVC spec 확인
kubectl -n cka-q004 get pvc data-pvc -o jsonpath='{.spec.resources.requests.storage}'
# 출력: 2Gi

# PVC 실제 용량 확인
kubectl -n cka-q004 get pvc data-pvc -o jsonpath='{.status.capacity.storage}'
# 출력: 2Gi (CSI 드라이버에 따라 시간이 걸릴 수 있음)

# Pod 상태 확인
kubectl -n cka-q004 get pod volume-pod
# STATUS: Running
```

## 검증

```bash
kubectl -n cka-q004 get pvc data-pvc
kubectl -n cka-q004 get pod volume-pod
```
