# Problem 072: etcd 스냅샷 백업 및 복원

| 항목 | 값 |
|------|-----|
| 문제 번호 | 072 |
| 도메인 | Cluster Architecture, Installation & Configuration |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 8분 |
| 네임스페이스 | cka-q072 |

## Context

네임스페이스 `cka-q072`에 etcd 클러스터 접속 정보가 담긴 ConfigMap `etcd-info`가 있습니다. 이 정보를 참고하여 etcd 백업 및 복원 스크립트를 작성해야 합니다.

ConfigMap `etcd-scripts`에 `backup.sh`와 `restore.sh` 스크립트를 완성하세요.

> 참고: https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/#backing-up-an-etcd-cluster

## Tasks

1. ConfigMap `etcd-info`에서 인증서 경로와 엔드포인트 정보를 확인하세요.

2. ConfigMap `etcd-scripts`의 `backup.sh`에 올바른 `etcdctl snapshot save` 명령어를 작성하세요:
   - `--endpoints=https://127.0.0.1:2379`
   - `--cacert=/etc/kubernetes/pki/etcd/ca.crt`
   - `--cert=/etc/kubernetes/pki/etcd/server.crt`
   - `--key=/etc/kubernetes/pki/etcd/server.key`
   - 스냅샷 저장 경로: `/tmp/etcd-backup.db`

3. ConfigMap `etcd-scripts`의 `restore.sh`에 올바른 `etcdctl snapshot restore` 명령어를 작성하세요:
   - 스냅샷 파일: `/tmp/etcd-backup.db`
   - `--data-dir=/var/lib/etcd-restored`

4. 수정된 ConfigMap을 클러스터에 적용하세요.

## Expected Outcome

- `backup.sh`에 `etcdctl snapshot save` 명령어가 모든 필수 플래그와 함께 포함됨
- `restore.sh`에 `etcdctl snapshot restore` 명령어가 `--data-dir` 플래그와 함께 포함됨

<details>
<summary>힌트 1</summary>

etcdctl 명령어의 기본 형식:
```bash
ETCDCTL_API=3 etcdctl snapshot save /tmp/etcd-backup.db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key
```

</details>

<details>
<summary>힌트 2</summary>

복원 명령어:
```bash
ETCDCTL_API=3 etcdctl snapshot restore /tmp/etcd-backup.db \
  --data-dir=/var/lib/etcd-restored
```

</details>

<details>
<summary>힌트 3</summary>

ConfigMap을 수정하려면:
```bash
kubectl -n cka-q072 edit configmap etcd-scripts
```

</details>
