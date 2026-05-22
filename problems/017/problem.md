# Problem 017: kube-controller-manager 복구 (시뮬레이션)

| 항목 | 값 |
|------|-----|
| 문제 번호 | 017 |
| 도메인 | Troubleshooting |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 8분 |
| 네임스페이스 | cka-q017 |

## Context

클러스터의 kube-controller-manager가 시작되지 않아 ReplicaSet, Deployment 등의 컨트롤러가 동작하지 않는 상황입니다. 이 문제는 시뮬레이션으로 제공됩니다. ConfigMap `controller-manager-broken-manifest`에 잘못된 static pod 매니페스트가 저장되어 있습니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. ConfigMap `controller-manager-broken-manifest`의 `manifest` 키를 확인하여 잘못된 설정을 찾으세요.

2. `error-log` 키의 에러 로그를 분석하여 원인을 파악하세요.

3. `--cluster-signing-cert-file`과 `--cluster-signing-key-file` 플래그의 경로가 잘못되어 있습니다. 올바른 경로로 수정하세요.
   - 잘못된 값: `/etc/kubernetes/pki/wrong-ca.crt`, `/etc/kubernetes/pki/wrong-ca.key`
   - 올바른 값: `/etc/kubernetes/pki/ca.crt`, `/etc/kubernetes/pki/ca.key`

4. 수정된 매니페스트를 ConfigMap `controller-manager-fixed-manifest`의 `manifest` 키로 생성하세요.

## Expected Outcome

- ConfigMap `controller-manager-fixed-manifest`가 네임스페이스 `cka-q017`에 존재
- `manifest` 키에 `--cluster-signing-cert-file=/etc/kubernetes/pki/ca.crt`가 포함됨
- `manifest` 키에 `--cluster-signing-key-file=/etc/kubernetes/pki/ca.key`가 포함됨

<details>
<summary>힌트 1</summary>

```bash
kubectl -n cka-q017 get configmap controller-manager-broken-manifest -o jsonpath='{.data.error-log}'
```

`open /etc/kubernetes/pki/wrong-ca.crt: no such file or directory` 에러를 확인하세요.

</details>

<details>
<summary>힌트 2</summary>

kube-controller-manager의 cluster signing 인증서는 기본적으로 CA 인증서(`ca.crt`, `ca.key`)를 사용합니다.

</details>

<details>
<summary>힌트 3</summary>

```bash
kubectl -n cka-q017 get configmap controller-manager-broken-manifest -o jsonpath='{.data.manifest}' | \
  sed 's/wrong-ca.crt/ca.crt/g; s/wrong-ca.key/ca.key/g' > /tmp/cm-fixed.yaml

kubectl -n cka-q017 create configmap controller-manager-fixed-manifest \
  --from-file=manifest=/tmp/cm-fixed.yaml
```

</details>
