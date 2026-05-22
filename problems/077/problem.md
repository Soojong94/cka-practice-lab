# Problem 077: CSI 드라이버 확인

| 항목 | 값 |
|------|-----|
| 문제 번호 | 077 |
| 도메인 | Cluster Architecture, Installation & Configuration |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 7분 |
| 네임스페이스 | cka-q077 |

## Context

네임스페이스 `cka-q077`에 답안을 작성할 ConfigMap `csi-info`가 있습니다. 클러스터의 CSI(Container Storage Interface) 드라이버와 StorageClass 관계를 조사하고 결과를 기록하세요.

> 참고: https://kubernetes.io/docs/concepts/storage/volumes/#csi

## Tasks

1. 클러스터에 등록된 CSI 드라이버 목록을 확인하고 ConfigMap `csi-info`의 `csi-drivers` 키에 기록하세요.
   - `kubectl get csidrivers` 명령어 사용

2. 클러스터의 StorageClass 목록을 확인하고 각 StorageClass의 provisioner를 ConfigMap `csi-info`의 `storage-classes` 키에 기록하세요.
   - 형식: `<StorageClass이름>: <provisioner>`

3. 기본(default) StorageClass를 확인하고 ConfigMap `csi-info`의 `default-storage-class` 키에 기록하세요.

4. 수정된 ConfigMap을 클러스터에 적용하세요.

## Expected Outcome

- `csi-drivers`: CSI 드라이버 목록 (예: `hostpath.csi.k8s.io`)
- `storage-classes`: StorageClass와 provisioner 매핑
- `default-storage-class`: 기본 StorageClass 이름

<details>
<summary>힌트 1</summary>

CSI 드라이버 확인:
```bash
kubectl get csidrivers
# 또는
kubectl get csidriver -o wide
```

</details>

<details>
<summary>힌트 2</summary>

StorageClass와 provisioner 확인:
```bash
kubectl get storageclass
kubectl get sc -o custom-columns=NAME:.metadata.name,PROVISIONER:.provisioner
```

</details>

<details>
<summary>힌트 3</summary>

기본 StorageClass는 annotation에 `storageclass.kubernetes.io/is-default-class: "true"`가 설정된 것입니다:
```bash
kubectl get sc -o jsonpath='{range .items[?(@.metadata.annotations.storageclass\.kubernetes\.io/is-default-class=="true")]}{.metadata.name}{end}'
```

</details>
