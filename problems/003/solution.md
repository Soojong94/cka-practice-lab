# Problem 003: 정답 풀이

## Step 1: 현재 reclaimPolicy 확인

```bash
kubectl get pv cka-q003-data-pv -o jsonpath='{.spec.persistentVolumeReclaimPolicy}'
# 출력: Delete
```

## Step 2: reclaimPolicy를 Retain으로 변경

```bash
kubectl patch pv cka-q003-data-pv -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'
```

## Step 3: Pod 삭제

```bash
kubectl -n cka-q003 delete pod data-writer
```

## Step 4: PVC 삭제

```bash
kubectl -n cka-q003 delete pvc data-pvc
```

## Step 5: PV 상태 확인

```bash
kubectl get pv cka-q003-data-pv
# STATUS가 Released여야 함 (Retain 정책으로 PV가 보존됨)
```
