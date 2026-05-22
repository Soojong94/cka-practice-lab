# Problem 027: Deployment rollout 실패 복구

| 항목 | 값 |
|------|-----|
| 문제 번호 | 027 |
| 도메인 | Troubleshooting |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 7분 |
| 네임스페이스 | cka-q027 |

## Context

네임스페이스 `cka-q027`에 `web-deploy` Deployment가 있습니다. 최근 이미지 업데이트 후 rollout이 실패하여 새 Pod들이 정상 시작되지 않고 있습니다. 이전 정상 버전으로 롤백해야 합니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. Deployment `web-deploy`의 현재 rollout 상태를 확인하세요.
   - `kubectl -n cka-q027 rollout status deployment/web-deploy`

2. rollout 히스토리를 확인하여 이전 정상 버전을 파악하세요.
   - `kubectl -n cka-q027 rollout history deployment/web-deploy`

3. 이전 정상 버전으로 롤백하세요.
   - 원래 이미지: `nginx:alpine`

4. 롤백 후 모든 replicas(3개)가 Ready 상태인지 확인하세요.

## Expected Outcome

- Deployment `web-deploy`가 Available 상태
- 3개의 replicas 모두 Ready
- 이미지가 `nginx:alpine`으로 복구됨
- `kubectl rollout status`가 "successfully rolled out" 출력

<details>
<summary>힌트 1</summary>

현재 상태 확인:
```bash
kubectl -n cka-q027 rollout status deployment/web-deploy
kubectl -n cka-q027 get pods
kubectl -n cka-q027 describe deployment web-deploy
```

</details>

<details>
<summary>힌트 2</summary>

rollout 히스토리 확인:
```bash
kubectl -n cka-q027 rollout history deployment/web-deploy
kubectl -n cka-q027 rollout history deployment/web-deploy --revision=1
```

</details>

<details>
<summary>힌트 3</summary>

이전 버전으로 롤백:
```bash
kubectl -n cka-q027 rollout undo deployment/web-deploy
# 또는 특정 revision으로:
kubectl -n cka-q027 rollout undo deployment/web-deploy --to-revision=1
```

</details>
