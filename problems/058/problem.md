# Problem 058: ClusterRole/ClusterRoleBinding

| 항목 | 값 |
|------|-----|
| 문제 번호 | 058 |
| 도메인 | Cluster Architecture, Installation & Configuration |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 8분 |
| 네임스페이스 | cka-q058 |

## Context

네임스페이스 `cka-q058`에 ServiceAccount `cluster-viewer`가 생성되어 있습니다. 이 ServiceAccount에 클러스터 전체의 노드와 네임스페이스를 조회할 수 있는 권한을 부여해야 합니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. 다음 스펙으로 ClusterRole을 생성하세요:
   - 이름: `node-viewer`
   - 리소스: `nodes`, `namespaces`
   - 동작(verbs): `get`, `list`, `watch`

2. 다음 스펙으로 ClusterRoleBinding을 생성하세요:
   - 이름: `node-viewer-binding`
   - ClusterRole 참조: `node-viewer`
   - Subject: ServiceAccount `cluster-viewer` (네임스페이스 `cka-q058`)

3. `kubectl auth can-i` 명령으로 ServiceAccount `cluster-viewer`가 nodes를 list할 수 있는지 확인하고, 결과를 네임스페이스 `cka-q058`의 ConfigMap `cluster-rbac-verify`의 `can-list-nodes` 키에 저장하세요.

4. 같은 ServiceAccount가 다른 네임스페이스(예: `default`)에서도 namespaces를 list할 수 있는지 확인하고, 결과를 같은 ConfigMap의 `can-list-namespaces` 키에 저장하세요.

5. 같은 ServiceAccount가 pods를 delete할 수 없는지 확인하고, 결과를 같은 ConfigMap의 `can-delete-pods` 키에 저장하세요.

## Expected Outcome

- ClusterRole `node-viewer` 존재
- ClusterRoleBinding `node-viewer-binding` 존재
- ConfigMap `cluster-rbac-verify`의 `can-list-nodes` = `yes`
- ConfigMap `cluster-rbac-verify`의 `can-list-namespaces` = `yes`
- ConfigMap `cluster-rbac-verify`의 `can-delete-pods` = `no`

<details>
<summary>힌트 1</summary>

ClusterRole은 네임스페이스에 속하지 않는 클러스터 범위 리소스입니다:
```bash
kubectl create clusterrole node-viewer --verb=get,list,watch --resource=nodes,namespaces
```

</details>

<details>
<summary>힌트 2</summary>

ClusterRoleBinding도 클러스터 범위입니다:
```bash
kubectl create clusterrolebinding node-viewer-binding --clusterrole=node-viewer --serviceaccount=cka-q058:cluster-viewer
```

</details>

<details>
<summary>힌트 3</summary>

ClusterRole은 모든 네임스페이스에서 동작합니다:
```bash
kubectl auth can-i list nodes --as=system:serviceaccount:cka-q058:cluster-viewer
kubectl -n default auth can-i list namespaces --as=system:serviceaccount:cka-q058:cluster-viewer
```

</details>
