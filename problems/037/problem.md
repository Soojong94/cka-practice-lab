# Problem 037: 컨트롤플레인 컴포넌트 확인 및 문서화

| 항목 | 값 |
|------|-----|
| 문제 번호 | 037 |
| 도메인 | Troubleshooting |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 10분 |
| 네임스페이스 | cka-q037 |

## Context

클러스터 관리자로서 현재 클러스터의 컨트롤플레인 컴포넌트 정보를 문서화해야 합니다. 네임스페이스 `cka-q037`에 `cluster-info`라는 ConfigMap이 준비되어 있으며, 각 컴포넌트의 실행 방식, 노드, 이미지 버전을 기록해야 합니다.

Docker Desktop 환경에서는 컨트롤플레인 컴포넌트가 static pod 또는 Deployment로 실행됩니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. 다음 컴포넌트의 실행 방식을 확인하세요 (static-pod 또는 deployment):
   - kube-apiserver
   - etcd
   - kube-scheduler
   - kube-controller-manager
   - coredns

2. 각 컴포넌트가 실행 중인 노드 이름을 확인하세요.

3. 각 컴포넌트의 컨테이너 이미지 버전을 확인하세요.

4. ConfigMap `cluster-info`를 업데이트하여 모든 필드를 채우세요:
   - `*-type`: `static-pod` 또는 `deployment`
   - `*-node`: 노드 이름 (예: `docker-desktop`)
   - `*-image`: 전체 이미지 이름 (예: `registry.k8s.io/kube-apiserver:v1.28.2`)

## Expected Outcome

- ConfigMap `cluster-info`의 모든 필드가 비어있지 않음
- 각 type 필드가 `static-pod` 또는 `deployment` 값을 가짐
- 각 node 필드에 실제 노드 이름이 기록됨
- 각 image 필드에 실제 이미지 이름이 기록됨

<details>
<summary>힌트 1</summary>

`kubectl -n kube-system get pods -o wide`로 컨트롤플레인 Pod 목록과 노드를 확인합니다.
Static pod는 이름 끝에 노드 이름이 붙습니다 (예: `kube-apiserver-docker-desktop`).

</details>

<details>
<summary>힌트 2</summary>

이미지 확인:
```bash
kubectl -n kube-system get pod <pod-name> -o jsonpath='{.spec.containers[0].image}'
```

</details>

<details>
<summary>힌트 3</summary>

ConfigMap 업데이트:
```bash
kubectl -n cka-q037 patch configmap cluster-info --type merge -p '{"data": {"kube-apiserver-type": "static-pod", ...}}'
```

</details>
