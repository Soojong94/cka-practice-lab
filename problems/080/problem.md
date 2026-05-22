# Problem 080: Cluster 전체 백업/복원 절차

| 항목 | 값 |
|------|-----|
| 문제 번호 | 080 |
| 도메인 | Cluster Architecture, Installation & Configuration |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 9분 |
| 네임스페이스 | cka-q080 |

## Context

네임스페이스 `cka-q080`에 답안을 작성할 ConfigMap `backup-procedure`가 있습니다. Kubernetes 클러스터의 전체 백업 및 복원 절차를 문서화하세요.

운영팀에서 재해 복구(DR) 계획을 수립하기 위해 클러스터 백업/복원 절차서가 필요합니다.

> 참고: https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/

## Tasks

1. ConfigMap `backup-procedure`의 `etcd-backup` 키에 etcd 스냅샷 백업 명령어를 기록하세요:
   - `etcdctl snapshot save` 명령어 (인증서 플래그 포함)
   - 스냅샷 저장 경로: `/backup/etcd-snapshot.db`

2. ConfigMap `backup-procedure`의 `cert-backup-paths` 키에 백업해야 할 인증서 디렉토리를 기록하세요:
   - `/etc/kubernetes/pki/` (전체 PKI 디렉토리)
   - `/etc/kubernetes/admin.conf`
   - `/etc/kubernetes/controller-manager.conf`
   - `/etc/kubernetes/scheduler.conf`

3. ConfigMap `backup-procedure`의 `kubeadm-config` 키에 kubeadm 설정 백업 명령어를 기록하세요:
   - `kubectl -n kube-system get configmap kubeadm-config -o yaml > /backup/kubeadm-config.yaml`

4. ConfigMap `backup-procedure`의 `restore-steps` 키에 복원 순서를 기록하세요:
   - Step 1: etcd 복원 (`etcdctl snapshot restore`)
   - Step 2: 인증서 복원 (PKI 디렉토리 복사)
   - Step 3: kubeadm 설정 복원
   - Step 4: kubelet 재시작 (`systemctl restart kubelet`)

5. 수정된 ConfigMap을 클러스터에 적용하세요.

## Expected Outcome

- `etcd-backup`: etcdctl snapshot save 명령어 (인증서 플래그 포함)
- `cert-backup-paths`: 백업 대상 인증서 경로 목록
- `kubeadm-config`: kubeadm 설정 백업 명령어
- `restore-steps`: 복원 절차 (4단계)

<details>
<summary>힌트 1</summary>

etcd 백업 명령어:
```bash
ETCDCTL_API=3 etcdctl snapshot save /backup/etcd-snapshot.db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key
```

</details>

<details>
<summary>힌트 2</summary>

인증서 백업은 전체 PKI 디렉토리를 복사하는 것이 가장 안전합니다:
```bash
cp -r /etc/kubernetes/pki/ /backup/pki/
cp /etc/kubernetes/admin.conf /backup/
```

</details>

<details>
<summary>힌트 3</summary>

복원 순서가 중요합니다:
1. etcd 데이터 복원 (클러스터 상태)
2. 인증서 복원 (컴포넌트 간 통신)
3. kubeadm 설정 복원 (클러스터 구성)
4. kubelet 재시작 (컨트롤 플레인 Pod 재생성)

</details>
