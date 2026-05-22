# Problem 040: Cluster Event 분석 및 로깅

| 항목 | 값 |
|------|-----|
| 문제 번호 | 040 |
| 도메인 | Troubleshooting |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 8분 |
| 네임스페이스 | cka-q040 |

## Context

네임스페이스 `cka-q040`에 여러 리소스가 배포되어 다양한 이벤트가 생성되었습니다. 클러스터 관리자로서 이벤트를 분석하고, 이벤트 조회 명령어를 스크립트 파일로 문서화해야 합니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. 네임스페이스 `cka-q040`의 이벤트를 시간순으로 확인하세요.

2. 실패한 Pod `failing-pod`의 이벤트를 확인하고 원인을 파악하세요.

3. `/tmp/cka-q040-events.sh` 스크립트 파일을 생성하고 다음 명령어를 포함하세요:
   - 네임스페이스의 모든 이벤트를 시간순 정렬하여 조회하는 명령
   - Warning 타입 이벤트만 필터링하는 명령
   - 특정 Pod(failing-pod)의 이벤트만 조회하는 명령

4. 스크립트 파일에 실행 권한을 부여하세요.

5. 실패한 Pod의 원인을 ConfigMap `event-analysis`에 기록하세요:
   - key: `failing-pod-reason`
   - value: 이미지 풀 실패 원인 (예: `ImagePullBackOff` 또는 `ErrImagePull`)

## Expected Outcome

- `/tmp/cka-q040-events.sh` 파일이 존재하고 실행 가능
- 스크립트에 올바른 kubectl 명령어가 포함됨
- ConfigMap `event-analysis`에 실패 원인이 기록됨

<details>
<summary>힌트 1</summary>

이벤트 시간순 정렬:
```bash
kubectl -n cka-q040 get events --sort-by='.lastTimestamp'
```

</details>

<details>
<summary>힌트 2</summary>

Warning 이벤트 필터링:
```bash
kubectl -n cka-q040 get events --field-selector type=Warning
```

</details>

<details>
<summary>힌트 3</summary>

특정 리소스의 이벤트:
```bash
kubectl -n cka-q040 get events --field-selector involvedObject.name=failing-pod
```

</details>
