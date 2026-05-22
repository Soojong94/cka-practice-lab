# Problem 054: StatefulSet 스케일링 및 관리

| 항목 | 값 |
|------|-----|
| 문제 번호 | 054 |
| 도메인 | Workloads & Scheduling |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 10분 |
| 네임스페이스 | cka-q054 |

## Context

네임스페이스 `cka-q054`에 StatefulSet `web`이 3개의 레플리카로 동작 중입니다. StatefulSet의 스케일링 동작을 이해하고, 순서대로 축소/확장하는 연습을 하세요.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. 현재 StatefulSet `web`의 상태를 확인하세요:
   - Pod 이름이 `web-0`, `web-1`, `web-2` 순서로 생성되었는지 확인

2. StatefulSet을 1개의 레플리카로 스케일 다운하세요:
   - `web-2`가 먼저 삭제되고, 그 다음 `web-1`이 삭제되는 순서 확인

3. StatefulSet을 다시 2개의 레플리카로 스케일 업하세요.

4. `web-0`과 `web-1`이 Running 상태인지 확인하세요.

## Expected Outcome

- StatefulSet `web`의 replicas가 2
- Pod `web-0`과 `web-1`이 Running 상태
- Headless Service `web-headless`가 존재

<details>
<summary>힌트 1</summary>

StatefulSet 스케일링:
```bash
kubectl -n cka-q054 scale statefulset web --replicas=1
kubectl -n cka-q054 scale statefulset web --replicas=2
```

</details>

<details>
<summary>힌트 2</summary>

StatefulSet은 순서대로 Pod를 생성/삭제합니다:
- 스케일 업: web-0 → web-1 → web-2 순서로 생성
- 스케일 다운: web-2 → web-1 → web-0 순서로 삭제 (역순)

</details>

<details>
<summary>힌트 3</summary>

StatefulSet 상태 확인:
```bash
kubectl -n cka-q054 get statefulset web
kubectl -n cka-q054 get pods -l app=web
kubectl -n cka-q054 rollout status statefulset/web
```

</details>
