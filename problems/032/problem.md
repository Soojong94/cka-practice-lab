# Problem 032: Pod 리소스 제한 초과 OOMKilled

| 항목 | 값 |
|------|-----|
| 문제 번호 | 032 |
| 도메인 | Troubleshooting |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 6분 |
| 네임스페이스 | cka-q032 |

## Context

네임스페이스 `cka-q032`에 `memory-hog`라는 Pod가 배포되었으나, 메모리 부족으로 인해 `OOMKilled` 상태로 반복 재시작되고 있습니다. 이 Pod는 약 50MB의 메모리를 사용하는 프로세스를 실행합니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. Pod `memory-hog`의 상태를 확인하고, OOMKilled 원인을 분석하세요.
   - `kubectl describe pod`로 Last State와 Reason을 확인

2. 현재 설정된 메모리 limit을 확인하세요.

3. Pod를 삭제하고, 메모리 limit을 `128Mi`로 증가시킨 새 Pod를 생성하세요.
   - requests: `64Mi`
   - limits: `128Mi`

4. 새 Pod가 `Running` 상태로 정상 동작하는지 확인하세요.

## Expected Outcome

- Pod `memory-hog`가 `Running` 상태
- Pod의 메모리 limit이 `128Mi`로 설정됨
- OOMKilled 없이 정상 동작

<details>
<summary>힌트 1</summary>

`kubectl -n cka-q032 describe pod memory-hog`로 Last State를 확인하면 OOMKilled reason을 볼 수 있습니다.

</details>

<details>
<summary>힌트 2</summary>

Pod는 직접 수정할 수 없으므로, 삭제 후 재생성해야 합니다:
```bash
kubectl -n cka-q032 delete pod memory-hog --grace-period=0 --force
```

</details>

<details>
<summary>힌트 3</summary>

새 Pod 생성 시 resources 섹션을 수정합니다:
```yaml
resources:
  requests:
    memory: "64Mi"
  limits:
    memory: "128Mi"
```

</details>
