# Problem 073: etcd 멤버 관리

| 항목 | 값 |
|------|-----|
| 문제 번호 | 073 |
| 도메인 | Cluster Architecture, Installation & Configuration |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 7분 |
| 네임스페이스 | cka-q073 |

## Context

네임스페이스 `cka-q073`에 etcd 클러스터 접속 정보가 담긴 ConfigMap `etcd-cluster-info`가 있습니다. 이 정보를 참고하여 etcd 멤버 관리 명령어를 작성해야 합니다.

ConfigMap `etcd-commands`에 각 명령어를 완성하세요.

> 참고: https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/

## Tasks

1. ConfigMap `etcd-commands`의 `member-list` 키에 etcd 멤버 목록을 조회하는 명령어를 작성하세요:
   - `etcdctl member list` 명령어 사용
   - 필수 플래그: `--endpoints`, `--cacert`, `--cert`, `--key`

2. ConfigMap `etcd-commands`의 `endpoint-health` 키에 엔드포인트 상태를 확인하는 명령어를 작성하세요:
   - `etcdctl endpoint health` 명령어 사용
   - 필수 플래그: `--endpoints`, `--cacert`, `--cert`, `--key`

3. ConfigMap `etcd-commands`의 `endpoint-status` 키에 엔드포인트 상세 상태를 확인하는 명령어를 작성하세요:
   - `etcdctl endpoint status` 명령어 사용
   - 필수 플래그: `--endpoints`, `--cacert`, `--cert`, `--key`

4. 수정된 ConfigMap을 클러스터에 적용하세요.

## Expected Outcome

- `member-list`: `etcdctl member list` + 인증서 플래그
- `endpoint-health`: `etcdctl endpoint health` + 인증서 플래그
- `endpoint-status`: `etcdctl endpoint status` + 인증서 플래그

<details>
<summary>힌트 1</summary>

etcdctl 명령어의 기본 형식:
```bash
ETCDCTL_API=3 etcdctl member list \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key
```

</details>

<details>
<summary>힌트 2</summary>

`endpoint health`는 etcd 엔드포인트의 응답 가능 여부를 확인하고, `endpoint status`는 리더 여부, DB 크기 등 상세 정보를 보여줍니다.

</details>

<details>
<summary>힌트 3</summary>

```bash
kubectl -n cka-q073 edit configmap etcd-commands
```

</details>
