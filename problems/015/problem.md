# Problem 015: kube-apiserver 장애 복구 (시뮬레이션)

| 항목 | 값 |
|------|-----|
| 문제 번호 | 015 |
| 도메인 | Troubleshooting |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 10분 |
| 네임스페이스 | cka-q015 |

## Context

클러스터의 kube-apiserver가 시작되지 않는 상황입니다. 이 문제는 시뮬레이션으로 제공됩니다. ConfigMap `apiserver-broken-manifest`에 잘못된 kube-apiserver static pod 매니페스트가 저장되어 있습니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. ConfigMap `apiserver-broken-manifest`의 `manifest` 키를 확인하여 잘못된 설정을 찾으세요.

2. `--etcd-servers` 플래그의 값이 잘못되어 있습니다. 올바른 etcd 엔드포인트 URL로 수정하세요.
   - 잘못된 값: `https://127.0.0.1:1234`
   - 올바른 값: `https://127.0.0.1:2379`

3. 수정된 매니페스트를 ConfigMap `apiserver-fixed-manifest`로 생성하세요.

4. ConfigMap `apiserver-fixed-manifest`의 `etcd-endpoint` 키에 올바른 etcd 엔드포인트를 기록하세요.

## Expected Outcome

- ConfigMap `apiserver-fixed-manifest`가 네임스페이스 `cka-q015`에 존재
- `manifest` 키에 `--etcd-servers=https://127.0.0.1:2379`가 포함됨
- `etcd-endpoint` 키의 값이 `https://127.0.0.1:2379`

<details>
<summary>힌트 1</summary>

```bash
kubectl -n cka-q015 get configmap apiserver-broken-manifest -o jsonpath='{.data.manifest}'
```

매니페스트에서 `--etcd-servers` 플래그를 찾으세요.

</details>

<details>
<summary>힌트 2</summary>

etcd의 기본 클라이언트 포트는 2379입니다. kube-apiserver는 이 포트를 통해 etcd와 통신합니다.

</details>

<details>
<summary>힌트 3</summary>

수정된 매니페스트를 ConfigMap으로 생성:
```bash
kubectl -n cka-q015 get configmap apiserver-broken-manifest -o jsonpath='{.data.manifest}' > /tmp/apiserver.yaml
# --etcd-servers=https://127.0.0.1:1234 → --etcd-servers=https://127.0.0.1:2379 수정
kubectl -n cka-q015 create configmap apiserver-fixed-manifest \
  --from-file=manifest=/tmp/apiserver.yaml \
  --from-literal=etcd-endpoint="https://127.0.0.1:2379"
```

</details>
