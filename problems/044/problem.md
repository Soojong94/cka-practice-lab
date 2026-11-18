# Problem 044: Taint/Toleration 활용

| 항목 | 값 |
|------|-----|
| 문제 번호 | 044 |
| 도메인 | Workloads & Scheduling |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 10분 |
| 네임스페이스 | cka-q044 |

## Context

클러스터의 노드에 `env=production:NoSchedule` taint가 설정되어 있습니다. Toleration을 사용하여 특정 Pod만 해당 노드에 스케줄링되도록 하고, 이후 taint를 제거하여 모든 Pod가 실행되도록 하세요.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. 네임스페이스 `cka-q044`에 Pod `prod-app`을 생성하세요:
   - 이미지: `nginx:1-alpine`
   - toleration: key=`env`, value=`production`, effect=`NoSchedule`, operator=`Equal`
   - 이 Pod는 taint가 있어도 스케줄되어야 합니다.

2. 네임스페이스 `cka-q044`에 Pod `dev-app`을 생성하세요:
   - 이미지: `nginx:1-alpine`
   - toleration 없음
   - 이 Pod는 taint 때문에 Pending 상태여야 합니다.

3. 노드에서 taint `env=production:NoSchedule`을 제거하세요.

4. taint 제거 후 `dev-app`도 Running 상태가 되는지 확인하세요.

## Expected Outcome

- `prod-app`: 처음부터 Running 상태
- `dev-app`: taint 제거 후 Running 상태
- 노드에 `env=production:NoSchedule` taint가 없음

<details>
<summary>힌트 1</summary>

Toleration 설정:
```yaml
tolerations:
- key: "env"
  operator: "Equal"
  value: "production"
  effect: "NoSchedule"
```

</details>

<details>
<summary>힌트 2</summary>

Taint 제거 명령:
```bash
kubectl taint nodes <node-name> env=production:NoSchedule-
```
마지막에 `-`를 붙이면 해당 taint가 제거됩니다.

</details>

<details>
<summary>힌트 3</summary>

노드 이름 확인:
```bash
kubectl get nodes   # taint는 일반 Pod가 뜰 수 있는 모든 노드에 걸려 있음
```

</details>
