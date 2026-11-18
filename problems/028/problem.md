# Problem 028: PVC Pending 상태 해결

| 항목 | 값 |
|------|-----|
| 문제 번호 | 028 |
| 도메인 | Troubleshooting |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 7분 |
| 네임스페이스 | cka-q028 |

## Context

네임스페이스 `cka-q028`에 PVC `data-pvc`가 Pending 상태입니다. 이 PVC는 존재하지 않는 StorageClass `fast-ssd`를 참조하고 있습니다. PVC가 Bound 상태가 되도록 문제를 해결하세요.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. PVC `data-pvc`의 상태를 확인하고 Pending 원인을 파악하세요.
   - `kubectl -n cka-q028 describe pvc data-pvc`

2. 현재 클러스터에서 사용 가능한 StorageClass를 확인하세요.
   - `kubectl get storageclass`

3. 다음 중 하나의 방법으로 PVC를 Bound 상태로 만드세요:
   - **방법 A**: StorageClass `fast-ssd`를 생성 (기존 `hostpath` StorageClass와 같은 provisioner 사용: Docker Desktop은 `docker.io/hostpath`, kind는 `rancher.io/local-path`)
   - **방법 B**: PVC를 삭제하고 기존 StorageClass(`hostpath`)를 사용하도록 재생성
   - **방법 C**: 수동으로 PV를 생성하여 PVC에 바인딩

4. PVC가 Bound 상태인지 확인하세요.
   - `volumeBindingMode: WaitForFirstConsumer`인 StorageClass(kind의 local-path 등)는 PVC를 사용하는 Pod가 생겨야 Bound됩니다. 이 경우 Pending이어도 정상으로 채점합니다.

## Expected Outcome

- PVC `data-pvc`가 Bound 상태
- PVC 용량이 1Gi 유지

<details>
<summary>힌트 1</summary>

PVC가 Pending인 이유 확인:
```bash
kubectl -n cka-q028 describe pvc data-pvc
# Events에서 "storageclass not found" 메시지 확인
```

</details>

<details>
<summary>힌트 2</summary>

Docker Desktop에서 사용 가능한 StorageClass:
```bash
kubectl get storageclass
# NAME       PROVISIONER          RECLAIMPOLICY
# hostpath   docker.io/hostpath   Delete
```

</details>

<details>
<summary>힌트 3</summary>

방법 A - StorageClass 생성:
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

방법 B - PVC 재생성:
```bash
kubectl -n cka-q028 delete pvc data-pvc
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

</details>
