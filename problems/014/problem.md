# Problem 014: kubelet 서비스 복구 (시뮬레이션)

| 항목 | 값 |
|------|-----|
| 문제 번호 | 014 |
| 도메인 | Troubleshooting |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 8분 |
| 네임스페이스 | cka-q014 |

## Context

클러스터의 워커 노드에서 kubelet 서비스가 중단되어 Pod가 스케줄링되지 않는 상황입니다. 이 문제는 시뮬레이션으로 제공됩니다. ConfigMap `kubelet-scenario`에 장애 상황의 로그가 기록되어 있습니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. ConfigMap `kubelet-scenario`의 `error-log` 키를 확인하여 kubelet 장애 원인을 분석하세요.

2. ConfigMap `kubelet-answer`를 생성하여 다음 키에 올바른 답을 작성하세요:
   - `cause`: 장애 원인 (예: "invalid kubelet configuration" 등)
   - `restart-command`: kubelet을 재시작하는 올바른 systemctl 명령어
   - `enable-command`: kubelet을 부팅 시 자동 시작하도록 설정하는 명령어
   - `check-command`: kubelet 상태를 확인하는 명령어

3. ConfigMap `kubelet-answer`의 `config-path` 키에 kubelet 설정 파일의 기본 경로를 작성하세요.

## Expected Outcome

- ConfigMap `kubelet-answer`가 네임스페이스 `cka-q014`에 존재
- `restart-command` 값이 `systemctl restart kubelet`
- `enable-command` 값이 `systemctl enable kubelet`
- `check-command` 값이 `systemctl status kubelet`
- `config-path` 값이 `/var/lib/kubelet/config.yaml`

<details>
<summary>힌트 1</summary>

```bash
kubectl -n cka-q014 get configmap kubelet-scenario -o yaml
```

</details>

<details>
<summary>힌트 2</summary>

kubelet은 systemd 서비스로 관리됩니다. `systemctl restart kubelet`으로 재시작할 수 있습니다.

</details>

<details>
<summary>힌트 3</summary>

```bash
kubectl -n cka-q014 create configmap kubelet-answer \
  --from-literal=cause="invalid kubelet configuration" \
  --from-literal=restart-command="systemctl restart kubelet" \
  --from-literal=enable-command="systemctl enable kubelet" \
  --from-literal=check-command="systemctl status kubelet" \
  --from-literal=config-path="/var/lib/kubelet/config.yaml"
```

</details>
