# Problem 029: Service CIDR 변경 (simulated)

| 항목 | 값 |
|------|-----|
| 문제 번호 | 029 |
| 도메인 | Troubleshooting |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 7분 |
| 네임스페이스 | cka-q029 |

## Context

클러스터의 Service CIDR 설정을 분석해야 합니다. ConfigMap `apiserver-manifest`에 kube-apiserver의 매니페스트가 저장되어 있습니다. 현재 Service CIDR을 확인하고, Service IP가 해당 범위 내에 있는지 검증하세요.

> 참고: 이 문제는 시뮬레이션입니다. 실제 apiserver 설정을 변경하지 않고 ConfigMap에 답을 작성합니다.

## Tasks

1. ConfigMap `apiserver-manifest`에서 `--service-cluster-ip-range` 값을 확인하세요.

2. 네임스페이스 `cka-q029`의 Service `test-svc`의 ClusterIP를 확인하세요.

3. 해당 ClusterIP가 service-cluster-ip-range 범위 내에 있는지 확인하세요.

4. 다음 스펙으로 ConfigMap을 생성하세요:
   - 이름: `service-cidr-answer`
   - 네임스페이스: `cka-q029`
   - 데이터:
     - `service-cidr`: 현재 service-cluster-ip-range 값
     - `test-svc-ip`: test-svc의 ClusterIP
     - `in-range`: "true" 또는 "false" (ClusterIP가 CIDR 범위 내인지)
     - `manifest-path`: kube-apiserver manifest 파일의 실제 경로

5. `manifest-path`에는 다음 값을 작성하세요:
   - `/etc/kubernetes/manifests/kube-apiserver.yaml`

## Expected Outcome

- ConfigMap `service-cidr-answer`가 네임스페이스 `cka-q029`에 존재
- `service-cidr` 값이 `10.96.0.0/12`
- `test-svc-ip` 값이 실제 Service ClusterIP와 일치
- `manifest-path` 값이 올바른 경로

<details>
<summary>힌트 1</summary>

```bash
kubectl -n cka-q029 get configmap apiserver-manifest -o jsonpath='{.data.kube-apiserver\.yaml}' | grep service-cluster-ip-range
```

</details>

<details>
<summary>힌트 2</summary>

Service CIDR `10.96.0.0/12`는 `10.96.0.0` ~ `10.111.255.255` 범위입니다.
Service의 ClusterIP가 이 범위 내에 있으면 "true"입니다.

kube-apiserver는 static pod이므로 manifest 경로는 `/etc/kubernetes/manifests/kube-apiserver.yaml`입니다.

</details>

<details>
<summary>힌트 3</summary>

```bash
SVC_IP=$(kubectl -n cka-q029 get svc test-svc -o jsonpath='{.spec.clusterIP}')

kubectl -n cka-q029 create configmap service-cidr-answer \
  --from-literal=service-cidr="10.96.0.0/12" \
  --from-literal=test-svc-ip="$SVC_IP" \
  --from-literal=in-range="true" \
  --from-literal=manifest-path="/etc/kubernetes/manifests/kube-apiserver.yaml"
```

</details>
