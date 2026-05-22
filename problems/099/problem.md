# Problem 099: Liveness/Readiness/Startup Probe

| 항목 | 값 |
|------|-----|
| 문제 번호 | 099 |
| 도메인 | Services & Networking |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 10분 |
| 네임스페이스 | cka-q099 |

## Context

네임스페이스 `cka-q099`에 `probe-app` Deployment가 동작 중이지만 어떤 Probe도 설정되어 있지 않습니다. 애플리케이션의 안정성과 가용성을 보장하기 위해 세 가지 Probe를 모두 구성해야 합니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. Deployment `probe-app`에 **livenessProbe**를 추가하세요:
   - httpGet: path `/healthz`, port `80`
   - periodSeconds: `10`

2. Deployment `probe-app`에 **readinessProbe**를 추가하세요:
   - httpGet: path `/`, port `80`
   - initialDelaySeconds: `5`

3. Deployment `probe-app`에 **startupProbe**를 추가하세요:
   - httpGet: path `/`, port `80`
   - failureThreshold: `30`
   - periodSeconds: `10`

4. Deployment가 정상적으로 업데이트되고 Pod가 Running 상태인지 확인하세요.

## Expected Outcome

- Deployment에 livenessProbe (httpGet /healthz:80, period 10s) 설정
- Deployment에 readinessProbe (httpGet /:80, initialDelay 5s) 설정
- Deployment에 startupProbe (httpGet /:80, failureThreshold 30, period 10s) 설정
- Pod가 Running 상태

<details>
<summary>힌트 1</summary>

`kubectl -n cka-q099 edit deployment probe-app`으로 직접 편집하거나 `kubectl patch`를 사용합니다.

</details>

<details>
<summary>힌트 2</summary>

```yaml
containers:
- name: nginx
  livenessProbe:
    httpGet:
      path: /healthz
      port: 80
    periodSeconds: 10
  readinessProbe:
    httpGet:
      path: /
      port: 80
    initialDelaySeconds: 5
  startupProbe:
    httpGet:
      path: /
      port: 80
    failureThreshold: 30
    periodSeconds: 10
```

</details>

<details>
<summary>힌트 3</summary>

startupProbe가 성공할 때까지 livenessProbe와 readinessProbe는 비활성화됩니다. startupProbe의 failureThreshold × periodSeconds가 애플리케이션 시작 시간보다 길어야 합니다.

</details>
