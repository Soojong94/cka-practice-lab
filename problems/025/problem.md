# Problem 025: etcd 클러스터 상태 확인 (simulated)

| 항목 | 값 |
|------|-----|
| 문제 번호 | 025 |
| 도메인 | Troubleshooting |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 8분 |
| 네임스페이스 | cka-q025 |

## Context

클러스터의 etcd 상태를 확인해야 합니다. ConfigMap `etcd-manifest`에 etcd Pod의 매니페스트가 저장되어 있습니다. 이 정보를 분석하여 올바른 etcdctl 명령어를 작성해야 합니다.

> 참고: 이 문제는 시뮬레이션입니다. 실제 etcd에 접속하지 않고 ConfigMap에 답을 작성합니다.

## Tasks

1. ConfigMap `etcd-manifest`의 `etcd-pod.yaml` 데이터에서 다음 정보를 추출하세요:
   - etcd CA 인증서 경로 (`--trusted-ca-file`)
   - etcd 서버 인증서 경로 (`--cert-file`)
   - etcd 서버 키 경로 (`--key-file`)
   - etcd 엔드포인트 (`--advertise-client-urls`)

2. 추출한 정보를 사용하여 `etcdctl endpoint health` 명령어를 작성하세요.

3. 다음 스펙으로 ConfigMap을 생성하세요:
   - 이름: `etcd-commands`
   - 네임스페이스: `cka-q025`
   - 데이터:
     - `ca-cert`: CA 인증서 경로
     - `server-cert`: 서버 인증서 경로
     - `server-key`: 서버 키 경로
     - `endpoint`: etcd 엔드포인트 URL
     - `health-command`: 완전한 etcdctl endpoint health 명령어

4. `health-command`는 다음 형식이어야 합니다:
   ```
   etcdctl --endpoints=<endpoint> --cacert=<ca-path> --cert=<cert-path> --key=<key-path> endpoint health
   ```

## Expected Outcome

- ConfigMap `etcd-commands`가 네임스페이스 `cka-q025`에 존재
- 인증서 경로가 etcd manifest와 일치
- `health-command`에 올바른 etcdctl 명령어 포함

<details>
<summary>힌트 1</summary>

```bash
kubectl -n cka-q025 get configmap etcd-manifest -o jsonpath='{.data.etcd-pod\.yaml}'
```

`--trusted-ca-file`, `--cert-file`, `--key-file`, `--advertise-client-urls` 값을 찾으세요.

</details>

<details>
<summary>힌트 2</summary>

etcd manifest에서 추출한 값:
- CA: `/etc/kubernetes/pki/etcd/ca.crt`
- Cert: `/etc/kubernetes/pki/etcd/server.crt`
- Key: `/etc/kubernetes/pki/etcd/server.key`
- Endpoint: `https://192.168.65.4:2379`

</details>

<details>
<summary>힌트 3</summary>

```bash
kubectl -n cka-q025 create configmap etcd-commands \
  --from-literal=ca-cert="/etc/kubernetes/pki/etcd/ca.crt" \
  --from-literal=server-cert="/etc/kubernetes/pki/etcd/server.crt" \
  --from-literal=server-key="/etc/kubernetes/pki/etcd/server.key" \
  --from-literal=endpoint="https://192.168.65.4:2379" \
  --from-literal=health-command="etcdctl --endpoints=https://192.168.65.4:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key endpoint health"
```

</details>
