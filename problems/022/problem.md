# Problem 022: Node NotReady 상태 해결 (simulated)

| 항목 | 값 |
|------|-----|
| 문제 번호 | 022 |
| 도메인 | Troubleshooting |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 8분 |
| 네임스페이스 | cka-q022 |

## Context

클러스터의 `worker-node-1` 노드가 `NotReady` 상태입니다. 운영팀에서 노드 상태 정보와 kubelet 로그를 ConfigMap으로 제공했습니다. 이 정보를 분석하여 원인을 진단하고 해결 방법을 제시해야 합니다.

> 참고: 이 문제는 시뮬레이션입니다. 실제 노드를 수정하지 않고 ConfigMap에 답을 작성합니다.

## Tasks

1. ConfigMap `node-describe-output`의 `node-status` 데이터를 확인하여 노드가 NotReady인 이유를 파악하세요.

2. ConfigMap `node-describe-output`의 `kubelet-logs` 데이터를 확인하여 구체적인 에러 원인을 파악하세요.

3. 다음 스펙으로 ConfigMap을 생성하세요:
   - 이름: `node-fix-answer`
   - 네임스페이스: `cka-q022`
   - 데이터:
     - `root-cause`: 문제의 근본 원인 (예: "kubelet certificate expired")
     - `fix-command`: 해결을 위한 명령어 (예: 인증서 갱신 명령)
     - `restart-command`: kubelet 재시작 명령

4. `fix-command`에는 다음 명령어를 작성하세요:
   - `kubeadm certs renew kubelet-client`

5. `restart-command`에는 다음 명령어를 작성하세요:
   - `systemctl restart kubelet`

## Expected Outcome

- ConfigMap `node-fix-answer`가 네임스페이스 `cka-q022`에 존재
- `root-cause` 값에 "certificate" 또는 "expired" 키워드 포함
- `fix-command` 값에 올바른 인증서 갱신 명령 포함
- `restart-command` 값에 kubelet 재시작 명령 포함

<details>
<summary>힌트 1</summary>

`kubectl -n cka-q022 get configmap node-describe-output -o jsonpath='{.data.node-status}'`로 노드 상태를 확인하세요.

</details>

<details>
<summary>힌트 2</summary>

kubelet 로그에서 "certificate has expired" 메시지를 찾으세요. kubelet의 TLS 인증서가 만료되면 노드가 NotReady 상태가 됩니다.

</details>

<details>
<summary>힌트 3</summary>

```bash
kubectl -n cka-q022 create configmap node-fix-answer \
  --from-literal=root-cause="kubelet certificate expired" \
  --from-literal=fix-command="kubeadm certs renew kubelet-client" \
  --from-literal=restart-command="systemctl restart kubelet"
```

</details>
