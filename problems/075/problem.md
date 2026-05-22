# Problem 075: Container Runtime 정보 확인 (CRI)

| 항목 | 값 |
|------|-----|
| 문제 번호 | 075 |
| 도메인 | Cluster Architecture, Installation & Configuration |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 7분 |
| 네임스페이스 | cka-q075 |

## Context

네임스페이스 `cka-q075`에 답안을 작성할 ConfigMap `cri-info`가 있습니다. 클러스터의 Container Runtime Interface(CRI) 정보를 조사하고 결과를 기록하세요.

Docker Desktop 환경에서 containerd가 컨테이너 런타임으로 사용됩니다.

> 참고: https://kubernetes.io/docs/concepts/architecture/cri/

## Tasks

1. 노드의 컨테이너 런타임 버전을 확인하고 ConfigMap `cri-info`의 `runtime-version` 키에 기록하세요.
   - `kubectl get nodes -o wide`의 CONTAINER-RUNTIME 열 값을 사용

2. ConfigMap `cri-info`의 `runtime-endpoint` 키에 containerd의 소켓 경로를 기록하세요.
   - 형식: `unix:///run/containerd/containerd.sock`

3. ConfigMap `cri-info`의 `list-containers-command` 키에 실행 중인 컨테이너를 조회하는 crictl 명령어를 기록하세요.

4. ConfigMap `cri-info`의 `inspect-command` 키에 특정 컨테이너를 상세 조회하는 crictl 명령어 형식을 기록하세요.

5. 수정된 ConfigMap을 클러스터에 적용하세요.

## Expected Outcome

- `runtime-version`: containerd 버전 정보 (예: `containerd://1.7.x`)
- `runtime-endpoint`: `unix:///run/containerd/containerd.sock`
- `list-containers-command`: `crictl ps` 또는 유사 명령어
- `inspect-command`: `crictl inspect <CONTAINER_ID>` 형식

<details>
<summary>힌트 1</summary>

노드의 컨테이너 런타임 정보 확인:
```bash
kubectl get nodes -o wide
# CONTAINER-RUNTIME 열 확인
```

</details>

<details>
<summary>힌트 2</summary>

crictl 주요 명령어:
- `crictl ps`: 실행 중인 컨테이너 목록
- `crictl inspect <ID>`: 컨테이너 상세 정보
- `crictl images`: 이미지 목록
- `crictl version`: 런타임 버전

</details>

<details>
<summary>힌트 3</summary>

containerd의 기본 소켓 경로는 `/run/containerd/containerd.sock`입니다.
Docker Desktop에서는 `unix:///run/containerd/containerd.sock`을 사용합니다.

</details>
