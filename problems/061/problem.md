# Problem 061: kubeadm 클러스터 업그레이드 시뮬레이션

| 항목 | 값 |
|------|-----|
| 문제 번호 | 061 |
| 도메인 | Cluster Architecture, Installation & Configuration |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 8분 |
| 네임스페이스 | cka-q061 |

## Context

네임스페이스 `cka-q061`에 ConfigMap `cluster-info`가 있으며, 현재 클러스터 버전과 업그레이드 목표 버전 정보가 포함되어 있습니다. 실제 업그레이드를 수행하지 않고, 올바른 업그레이드 절차를 문서화해야 합니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. ConfigMap `cluster-info`에서 현재 버전과 목표 버전을 확인하세요.

2. 네임스페이스 `cka-q061`에 ConfigMap `upgrade-procedure`를 생성하고, `step1` 키에 control-plane 노드 업그레이드 전 수행할 drain 명령을 작성하세요. (노드 이름: docker-desktop)

3. 같은 ConfigMap의 `step2` 키에 kubeadm upgrade 명령 시퀀스를 작성하세요. (kubeadm upgrade plan → kubeadm upgrade apply v1.29.0)

4. 같은 ConfigMap의 `step3` 키에 kubelet과 kubectl 업그레이드 후 노드를 다시 스케줄 가능하게 만드는 명령을 작성하세요. (systemctl restart kubelet → kubectl uncordon)

5. 같은 ConfigMap의 `upgrade-order` 키에 전체 업그레이드 순서를 작성하세요: `drain,upgrade-kubeadm,upgrade-apply,upgrade-kubelet,restart-kubelet,uncordon`

## Expected Outcome

- ConfigMap `upgrade-procedure`가 존재
- `step1`: drain 명령 포함
- `step2`: kubeadm upgrade plan/apply 명령 포함
- `step3`: uncordon 명령 포함
- `upgrade-order`: 올바른 순서 문자열

<details>
<summary>힌트 1</summary>

노드 drain 명령:
```bash
kubectl drain docker-desktop --ignore-daemonsets --delete-emptydir-data
```

</details>

<details>
<summary>힌트 2</summary>

kubeadm 업그레이드 순서:
1. `kubeadm upgrade plan`
2. `kubeadm upgrade apply v1.29.0`
3. `apt-get install kubelet=1.29.0-00 kubectl=1.29.0-00` (또는 해당 패키지 매니저)
4. `systemctl daemon-reload && systemctl restart kubelet`

</details>

<details>
<summary>힌트 3</summary>

업그레이드 후 노드 복구:
```bash
kubectl uncordon docker-desktop
```

</details>
