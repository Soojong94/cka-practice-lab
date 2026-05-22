# Problem 081: ClusterIP Service 생성 및 테스트

| 항목 | 값 |
|------|-----|
| 문제 번호 | 081 |
| 도메인 | Services & Networking |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 7분 |
| 네임스페이스 | cka-q081 |

## Context

네임스페이스 `cka-q081`에 `web`이라는 Deployment가 nginx 컨테이너 2개 레플리카로 동작 중입니다. 이 Deployment에 대한 ClusterIP Service를 생성하고, 클러스터 내부에서 접근 가능한지 테스트해야 합니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. 네임스페이스 `cka-q081`에 다음 스펙으로 ClusterIP Service를 생성하세요:
   - 이름: `web-svc`
   - 타입: `ClusterIP`
   - 포트: `80` (targetPort: `80`)
   - selector: `app: web`

2. Service의 Endpoints가 정상적으로 등록되었는지 확인하세요 (2개의 Pod IP가 등록되어야 함).

3. 테스트용 Pod `test-pod`를 생성하여 Service에 접근 가능한지 확인하세요:
   - 이미지: `curlimages/curl:latest`
   - 명령: `curl -s http://web-svc.cka-q081.svc.cluster.local` 실행 결과를 확인

4. 테스트 결과를 ConfigMap `curl-result`에 저장하세요:
   - key: `result`
   - value: curl 명령의 출력 결과 (nginx 기본 페이지 내용)

## Expected Outcome

- `kubectl -n cka-q081 get svc web-svc` 실행 시 ClusterIP 타입 Service 확인
- `kubectl -n cka-q081 get endpoints web-svc` 실행 시 2개의 엔드포인트 확인
- `test-pod`에서 Service로 curl 요청 성공
- ConfigMap `curl-result`에 결과 저장됨

<details>
<summary>힌트 1</summary>

ClusterIP Service는 `kubectl expose deployment web --name=web-svc --port=80 --target-port=80` 또는 YAML로 생성할 수 있습니다.

</details>

<details>
<summary>힌트 2</summary>

테스트 Pod에서 Service에 접근할 때 FQDN 형식은 `<service-name>.<namespace>.svc.cluster.local`입니다.

</details>

<details>
<summary>힌트 3</summary>

ConfigMap 생성: `kubectl -n cka-q081 create configmap curl-result --from-literal=result="$(curl 결과)"`

</details>
