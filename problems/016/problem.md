# Problem 016: kube-scheduler 장애 복구 (시뮬레이션)

| 항목 | 값 |
|------|-----|
| 문제 번호 | 016 |
| 도메인 | Troubleshooting |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 8분 |
| 네임스페이스 | cka-q016 |

## Context

클러스터의 kube-scheduler가 시작되지 않아 새로운 Pod가 스케줄링되지 않는 상황입니다. 이 문제는 시뮬레이션으로 제공됩니다. ConfigMap `scheduler-broken-manifest`에 잘못된 kube-scheduler static pod 매니페스트가 저장되어 있습니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. ConfigMap `scheduler-broken-manifest`의 `manifest` 키를 확인하여 잘못된 설정을 찾으세요.

2. `error-log` 키의 에러 로그를 분석하여 원인을 파악하세요.

3. `--kubeconfig`, `--authentication-kubeconfig`, `--authorization-kubeconfig` 플래그의 경로가 잘못되어 있습니다. 올바른 경로로 수정하세요.
   - 잘못된 경로: `/etc/kubernetes/scheduler-wrong.conf`
   - 올바른 경로: `/etc/kubernetes/scheduler.conf`

4. 수정된 매니페스트를 ConfigMap `scheduler-fixed-manifest`의 `manifest` 키로 생성하세요.

## Expected Outcome

- ConfigMap `scheduler-fixed-manifest`가 네임스페이스 `cka-q016`에 존재
- `manifest` 키에 `--kubeconfig=/etc/kubernetes/scheduler.conf`가 포함됨
- `manifest` 키에 `--authentication-kubeconfig=/etc/kubernetes/scheduler.conf`가 포함됨
- `manifest` 키에 `--authorization-kubeconfig=/etc/kubernetes/scheduler.conf`가 포함됨

<details>
<summary>힌트 1</summary>

```bash
kubectl -n cka-q016 get configmap scheduler-broken-manifest -o jsonpath='{.data.error-log}'
```

`open /etc/kubernetes/scheduler-wrong.conf: no such file or directory` 에러를 확인하세요.

</details>

<details>
<summary>힌트 2</summary>

kube-scheduler의 kubeconfig 파일은 기본적으로 `/etc/kubernetes/scheduler.conf`에 위치합니다.

</details>

<details>
<summary>힌트 3</summary>

```bash
kubectl -n cka-q016 get configmap scheduler-broken-manifest -o jsonpath='{.data.manifest}' | \
  sed 's/scheduler-wrong.conf/scheduler.conf/g' > /tmp/scheduler-fixed.yaml

kubectl -n cka-q016 create configmap scheduler-fixed-manifest \
  --from-file=manifest=/tmp/scheduler-fixed.yaml
```

</details>
