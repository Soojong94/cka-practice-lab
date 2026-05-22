# Problem 045: Static Pod 생성 및 서비스 노출

| 항목 | 값 |
|------|-----|
| 문제 번호 | 045 |
| 도메인 | Workloads & Scheduling |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 10분 |
| 네임스페이스 | cka-q045 |

## Context

Static Pod는 kubelet이 직접 관리하는 Pod입니다. Docker Desktop 환경에서는 `/etc/kubernetes/manifests` 디렉토리에 직접 접근이 어려우므로, Static Pod와 동일한 스펙의 Pod를 생성하고 서비스로 노출하는 연습을 합니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. 네임스페이스 `cka-q045`에 다음 스펙으로 Pod를 생성하세요 (Static Pod 시뮬레이션):
   - 이름: `static-web`
   - 이미지: `nginx:1-alpine`
   - 레이블: `role=static-web`
   - 포트: containerPort `80`

2. ConfigMap `static-pod-manifest`를 생성하여 Static Pod 매니페스트를 저장하세요:
   - ConfigMap에 `static-web.yaml` 키로 Pod 매니페스트 YAML을 저장

3. Pod `static-web`을 NodePort 타입 Service로 노출하세요:
   - Service 이름: `static-web-svc`
   - 포트: 80
   - targetPort: 80
   - selector: `role=static-web`

4. Service가 정상적으로 Pod에 연결되는지 확인하세요.

## Expected Outcome

- Pod `static-web`이 Running 상태
- ConfigMap `static-pod-manifest`에 매니페스트 저장됨
- NodePort Service `static-web-svc`가 Pod를 정상적으로 노출

<details>
<summary>힌트 1</summary>

Static Pod는 보통 `/etc/kubernetes/manifests/` 디렉토리에 YAML 파일을 배치하면 kubelet이 자동으로 생성합니다. 이 문제에서는 동일한 매니페스트를 ConfigMap에 저장하고 수동으로 Pod를 생성합니다.

</details>

<details>
<summary>힌트 2</summary>

ConfigMap에 파일 내용을 저장하려면:
```bash
kubectl -n cka-q045 create configmap static-pod-manifest --from-file=static-web.yaml=./manifest.yaml
```
또는 `--from-literal`로 직접 YAML 문자열을 전달할 수 있습니다.

</details>

<details>
<summary>힌트 3</summary>

NodePort Service 생성:
```bash
kubectl -n cka-q045 expose pod static-web --name=static-web-svc --type=NodePort --port=80 --target-port=80
```
또는 selector를 직접 지정하여 Service YAML을 작성합니다.

</details>
