# Problem 047: HPA 구성 (CPU 기반 오토스케일링)

| 항목 | 값 |
|------|-----|
| 문제 번호 | 047 |
| 도메인 | Workloads & Scheduling |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 8분 |
| 네임스페이스 | cka-q047 |

## Context

네임스페이스 `cka-q047`에 Deployment `hpa-target`이 동작 중입니다. CPU 사용량에 따라 자동으로 스케일링되도록 HPA(Horizontal Pod Autoscaler)를 구성하세요.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. 기존 Deployment `hpa-target`에 리소스 요청이 설정되어 있는지 확인하세요 (cpu: 100m).

2. 다음 스펙으로 HPA를 생성하세요:
   - 이름: `hpa-target`
   - 대상: Deployment `hpa-target`
   - 최소 레플리카: `2`
   - 최대 레플리카: `5`
   - 타겟 CPU 사용률: `50%`

3. HPA가 생성되었고 Deployment가 최소 2개의 레플리카로 스케일되었는지 확인하세요.

4. `kubectl get hpa -n cka-q047`으로 HPA 상태를 확인하세요.

## Expected Outcome

- HPA `hpa-target`이 존재하며 올바른 설정 (min=2, max=5, target=50%)
- Deployment가 최소 2개의 레플리카로 실행 중
- `kubectl get hpa` 출력에서 TARGETS 컬럼에 CPU 사용률 표시

<details>
<summary>힌트 1</summary>

HPA 생성 명령:
```bash
kubectl -n cka-q047 autoscale deployment hpa-target --min=2 --max=5 --cpu-percent=50
```

</details>

<details>
<summary>힌트 2</summary>

HPA가 동작하려면 Deployment의 컨테이너에 `resources.requests.cpu`가 설정되어 있어야 합니다. metrics-server도 필요합니다.

</details>

<details>
<summary>힌트 3</summary>

HPA 상태 확인:
```bash
kubectl -n cka-q047 get hpa hpa-target
kubectl -n cka-q047 describe hpa hpa-target
```
TARGETS에 `<unknown>/50%`가 표시되면 metrics-server가 아직 메트릭을 수집하지 못한 것입니다.

</details>
