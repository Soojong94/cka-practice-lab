# Problem 034: HPA 스케일링 미동작 해결

| 항목 | 값 |
|------|-----|
| 문제 번호 | 034 |
| 도메인 | Troubleshooting |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 8분 |
| 네임스페이스 | cka-q034 |

## Context

네임스페이스 `cka-q034`에 `web-deploy` Deployment와 `web-hpa` HorizontalPodAutoscaler가 설정되어 있습니다. HPA는 CPU 사용률 50%를 기준으로 스케일링하도록 구성되었으나, `kubectl get hpa`에서 TARGETS가 `<unknown>/50%`로 표시되며 스케일링이 동작하지 않습니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. `kubectl get hpa -n cka-q034`로 HPA 상태를 확인하고, TARGETS가 `<unknown>`인 원인을 분석하세요.

2. `kubectl describe hpa web-hpa -n cka-q034`로 상세 이벤트를 확인하세요.

3. Deployment `web-deploy`에 CPU resource requests를 추가하세요:
   - requests: `cpu: 50m`
   - limits: `cpu: 200m`

4. HPA가 정상적으로 CPU 사용률을 계산하는지 확인하세요.
   - TARGETS에 실제 퍼센트 값이 표시되어야 합니다 (metrics-server 설치 여부에 따라 0% 또는 실제 값)

## Expected Outcome

- Deployment `web-deploy`에 CPU resource requests가 설정됨
- HPA가 `<unknown>` 대신 실제 메트릭을 표시 (metrics-server가 있는 경우)
- Deployment의 containers에 resources.requests.cpu가 존재

<details>
<summary>힌트 1</summary>

HPA가 CPU 사용률을 계산하려면 Pod에 `resources.requests.cpu`가 반드시 설정되어 있어야 합니다. 이 값이 없으면 HPA는 사용률 비율을 계산할 수 없습니다.

</details>

<details>
<summary>힌트 2</summary>

Deployment를 수정하여 resource requests를 추가합니다:
```bash
kubectl -n cka-q034 edit deployment web-deploy
```

</details>

<details>
<summary>힌트 3</summary>

```yaml
containers:
- name: nginx
  image: nginx:1.24-alpine
  resources:
    requests:
      cpu: "50m"
    limits:
      cpu: "200m"
```

</details>
