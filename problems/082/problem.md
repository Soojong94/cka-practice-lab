# Problem 082: NodePort Service 구성

| 항목 | 값 |
|------|-----|
| 문제 번호 | 082 |
| 도메인 | Services & Networking |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 6분 |
| 네임스페이스 | cka-q082 |

## Context

네임스페이스 `cka-q082`에 `api`라는 Deployment가 nginx 컨테이너로 동작 중입니다. 이 애플리케이션을 클러스터 외부에서도 접근할 수 있도록 NodePort Service를 구성해야 합니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. 네임스페이스 `cka-q082`에 다음 스펙으로 NodePort Service를 생성하세요:
   - 이름: `api-nodeport`
   - 타입: `NodePort`
   - 포트: `80` (targetPort: `80`)
   - nodePort: `30080`
   - selector: `app: api`

2. Service의 Endpoints가 정상적으로 등록되었는지 확인하세요.

3. NodePort를 통해 접근 가능한지 확인하세요:
   - `curl http://localhost:30080` 으로 nginx 응답 확인

## Expected Outcome

- `kubectl -n cka-q082 get svc api-nodeport` 실행 시 NodePort 타입, nodePort=30080 확인
- `kubectl -n cka-q082 get endpoints api-nodeport` 실행 시 엔드포인트 확인
- `localhost:30080`으로 접근 시 nginx 기본 페이지 응답

<details>
<summary>힌트 1</summary>

NodePort Service YAML에서 `spec.type: NodePort`와 `spec.ports[].nodePort: 30080`을 지정합니다.

</details>

<details>
<summary>힌트 2</summary>

```yaml
apiVersion: v1
kind: Service
metadata:
  name: api-nodeport
spec:
  type: NodePort
  selector:
    app: api
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
```

</details>

<details>
<summary>힌트 3</summary>

Docker Desktop 환경에서는 NodePort가 localhost로 직접 접근 가능합니다.

</details>
