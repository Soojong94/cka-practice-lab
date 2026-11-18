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
# CSI 드라이버가 없는 클러스터(Docker Desktop, kind 등)는 "none"으로 기록
CSI_DRIVERS=$(kubectl get csidrivers -o jsonpath='{.items[*].metadata.name}' 2>/dev/null)
CSI_DRIVERS=${CSI_DRIVERS:-none}
# "<이름>: <provisioner>" 형식, StorageClass가 여러 개면 여러 줄
SC_INFO=$(kubectl get sc -o jsonpath='{range .items[*]}{.metadata.name}: {.provisioner}{"\n"}{end}')
DEFAULT_SC=$(kubectl get sc -o jsonpath='{range .items[?(@.metadata.annotations.storageclass\.kubernetes\.io/is-default-class=="true")]}{.metadata.name}{end}' 2>/dev/null)

# 여러 줄 값도 안전하게 넣도록 --from-literal 사용 (heredoc YAML은 들여쓰기가 깨짐)
kubectl -n cka-q077 create configmap csi-info \
  --from-literal=csi-drivers="$CSI_DRIVERS" \
  --from-literal=storage-classes="$SC_INFO" \
  --from-literal=default-storage-class="$DEFAULT_SC" \
  --dry-run=client -o yaml | kubectl apply -f -
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
