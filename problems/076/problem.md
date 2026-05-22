# Problem 076: CNI 플러그인 확인 및 설정

| 항목 | 값 |
|------|-----|
| 문제 번호 | 076 |
| 도메인 | Cluster Architecture, Installation & Configuration |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 7분 |
| 네임스페이스 | cka-q076 |

## Context

네임스페이스 `cka-q076`에 답안을 작성할 ConfigMap `cni-info`가 있습니다. 클러스터의 CNI(Container Network Interface) 플러그인 정보를 조사하고 결과를 기록하세요.

Docker Desktop 환경에서는 기본 CNI 플러그인이 사용됩니다.

> 참고: https://kubernetes.io/docs/concepts/cluster-administration/networking/

## Tasks

1. 현재 클러스터에서 사용 중인 CNI 플러그인 이름을 확인하고 ConfigMap `cni-info`의 `cni-plugin` 키에 기록하세요.
   - kube-system 네임스페이스의 Pod/DaemonSet을 확인하거나 CNI 설정 디렉토리를 확인

2. CNI 설정 파일의 경로를 ConfigMap `cni-info`의 `config-path` 키에 기록하세요.
   - 기본 경로: `/etc/cni/net.d/`

3. 클러스터의 Pod CIDR을 확인하고 ConfigMap `cni-info`의 `pod-cidr` 키에 기록하세요.
   - `kubectl cluster-info dump` 또는 노드 정보에서 확인

4. 수정된 ConfigMap을 클러스터에 적용하세요.

## Expected Outcome

- `cni-plugin`: CNI 플러그인 이름 (예: `kindnet`, `vpnkit`, `calico` 등)
- `config-path`: `/etc/cni/net.d/`
- `pod-cidr`: Pod 네트워크 CIDR (예: `10.244.0.0/16`)

<details>
<summary>힌트 1</summary>

CNI 플러그인 확인 방법:
```bash
# kube-system에서 네트워크 관련 Pod 확인
kubectl -n kube-system get pods
kubectl -n kube-system get daemonsets
```

</details>

<details>
<summary>힌트 2</summary>

Pod CIDR 확인 방법:
```bash
kubectl get nodes -o jsonpath='{.items[*].spec.podCIDR}'
# 또는
kubectl cluster-info dump | grep -m 1 cluster-cidr
```

</details>

<details>
<summary>힌트 3</summary>

Docker Desktop에서는 `vpnkit` 또는 `kindnet` 등의 CNI가 사용될 수 있습니다. kube-system 네임스페이스의 DaemonSet을 확인하세요.

</details>
