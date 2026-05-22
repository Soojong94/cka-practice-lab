# Problem 077: 정답 풀이

## Step 1: CSI 드라이버 확인

```bash
kubectl get csidrivers
```

## Step 2: StorageClass 확인

```bash
kubectl get storageclass
kubectl get sc -o custom-columns=NAME:.metadata.name,PROVISIONER:.provisioner
```

## Step 3: 기본 StorageClass 확인

```bash
kubectl get sc -o jsonpath='{range .items[?(@.metadata.annotations.storageclass\.kubernetes\.io/is-default-class=="true")]}{.metadata.name}{end}'
```

## Step 4: ConfigMap 수정

```bash
# Docker Desktop 환경 기준
CSI_DRIVERS=$(kubectl get csidrivers -o jsonpath='{.items[*].metadata.name}' 2>/dev/null || echo "none")
SC_INFO=$(kubectl get sc -o custom-columns=NAME:.metadata.name,PROVISIONER:.provisioner --no-headers 2>/dev/null)
DEFAULT_SC=$(kubectl get sc -o jsonpath='{range .items[?(@.metadata.annotations.storageclass\.kubernetes\.io/is-default-class=="true")]}{.metadata.name}{end}' 2>/dev/null)

kubectl -n cka-q077 apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: csi-info
  namespace: cka-q077
data:
  csi-drivers: "$CSI_DRIVERS"
  storage-classes: |
    $SC_INFO
  default-storage-class: "$DEFAULT_SC"
EOF
```

## 핵심 개념

- **CSI (Container Storage Interface)**: 스토리지 벤더가 Kubernetes에 스토리지를 제공하기 위한 표준 인터페이스
- **CSIDriver**: 클러스터에 등록된 CSI 드라이버 정보를 나타내는 리소스
- **StorageClass**: 동적 프로비저닝을 위한 스토리지 클래스 (provisioner 필드가 CSI 드라이버를 참조)
- **Default StorageClass**: PVC에 storageClassName을 지정하지 않으면 자동으로 사용되는 StorageClass

## 검증

```bash
kubectl -n cka-q077 get configmap csi-info -o yaml
```
