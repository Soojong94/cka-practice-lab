# Problem 074: kubelet 설정 확인 및 수정

| 항목 | 값 |
|------|-----|
| 문제 번호 | 074 |
| 도메인 | Cluster Architecture, Installation & Configuration |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 8분 |
| 네임스페이스 | cka-q074 |

## Context

네임스페이스 `cka-q074`에 kubelet 설정 파일 내용이 담긴 ConfigMap `kubelet-config`가 있습니다. 이 설정에는 여러 오류가 포함되어 있습니다. 문제를 식별하고 수정하세요.

> 참고: https://kubernetes.io/docs/reference/config-api/kubelet-config.v1beta1/

## Tasks

1. ConfigMap `kubelet-config`의 `config.yaml` 내용을 확인하고 다음 오류를 수정하세요:
   - `clusterDNS`가 잘못된 IP(`10.96.0.1`)로 설정됨 → `10.96.0.10`으로 수정
   - `staticPodPath`가 잘못된 경로(`/etc/kubernetes/static-pods`)로 설정됨 → `/etc/kubernetes/manifests`로 수정
   - `authentication.anonymous.enabled`가 `true`로 설정됨 → `false`로 수정

2. `authentication.webhook.enabled`가 누락됨 → `true`로 추가하세요.

3. `authorization.mode`가 누락됨 → `Webhook`으로 추가하세요.

4. 수정된 ConfigMap을 클러스터에 적용하세요.

## Expected Outcome

- `clusterDNS: ["10.96.0.10"]`
- `staticPodPath: /etc/kubernetes/manifests`
- `authentication.anonymous.enabled: false`
- `authentication.webhook.enabled: true`
- `authorization.mode: Webhook`

<details>
<summary>힌트 1</summary>

kubelet의 기본 DNS 서비스 IP는 `10.96.0.10`입니다 (CoreDNS Service의 ClusterIP).

</details>

<details>
<summary>힌트 2</summary>

Static Pod 매니페스트의 기본 경로는 `/etc/kubernetes/manifests`입니다. kube-apiserver, etcd 등의 컨트롤 플레인 컴포넌트가 여기에 위치합니다.

</details>

<details>
<summary>힌트 3</summary>

보안을 위해 anonymous 인증은 비활성화하고, webhook 인증과 authorization을 활성화해야 합니다:
```yaml
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
authorization:
  mode: Webhook
```

</details>
