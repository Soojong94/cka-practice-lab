# Problem 049: Rolling Update 전략 설정

| 항목 | 값 |
|------|-----|
| 문제 번호 | 049 |
| 도메인 | Workloads & Scheduling |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 10분 |
| 네임스페이스 | cka-q049 |

## Context

네임스페이스 `cka-q049`에 Deployment `web`이 4개의 레플리카로 동작 중입니다. 무중단 배포를 위해 Rolling Update 전략을 설정하고, 이미지를 업데이트한 후 롤백하세요.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. Deployment `web`의 Rolling Update 전략을 설정하세요:
   - strategy type: `RollingUpdate`
   - maxSurge: `1`
   - maxUnavailable: `0`

2. 이미지를 `nginx:1.25-alpine`으로 업데이트하세요.

3. 롤아웃이 완료되었는지 확인하세요:
   - `kubectl -n cka-q049 rollout status deployment/web`

4. 이전 버전(`nginx:1.24-alpine`)으로 롤백하세요:
   - `kubectl -n cka-q049 rollout undo deployment/web`

5. 롤아웃 히스토리에 2개 이상의 리비전이 있는지 확인하세요.

## Expected Outcome

- Deployment strategy: maxSurge=1, maxUnavailable=0
- 현재 이미지: `nginx:1.24-alpine` (롤백 완료)
- 롤아웃 히스토리에 2개 이상의 리비전 존재

<details>
<summary>힌트 1</summary>

Rolling Update 전략 설정:
```bash
kubectl -n cka-q049 patch deployment web -p '{"spec":{"strategy":{"type":"RollingUpdate","rollingUpdate":{"maxSurge":1,"maxUnavailable":0}}}}'
```

</details>

<details>
<summary>힌트 2</summary>

이미지 업데이트:
```bash
kubectl -n cka-q049 set image deployment/web nginx=nginx:1.25-alpine
```

</details>

<details>
<summary>힌트 3</summary>

롤백 및 히스토리 확인:
```bash
kubectl -n cka-q049 rollout undo deployment/web
kubectl -n cka-q049 rollout history deployment/web
```

</details>
