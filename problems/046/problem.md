# Problem 046: Kustomize로 환경별 배포

| 항목 | 값 |
|------|-----|
| 문제 번호 | 046 |
| 도메인 | Workloads & Scheduling |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 12분 |
| 네임스페이스 | cka-q046-staging, cka-q046-prod |

## Context

Kustomize를 사용하여 동일한 애플리케이션을 staging과 production 환경에 서로 다른 설정으로 배포해야 합니다. Base 매니페스트를 기반으로 환경별 오버레이를 적용하세요.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. `/tmp/kustomize/base` 디렉토리에 base kustomization을 작성하세요:
   - Deployment `kustom-app` (image: nginx:1-alpine, replicas: 1)
   - Service `kustom-app-svc` (port: 80)
   - `kustomization.yaml` 파일 포함

2. `/tmp/kustomize/overlays/staging` 디렉토리에 staging 오버레이를 작성하세요:
   - namespace: `cka-q046-staging`
   - replicas: 1 (base와 동일)

3. `/tmp/kustomize/overlays/prod` 디렉토리에 production 오버레이를 작성하세요:
   - namespace: `cka-q046-prod`
   - replicas: 3

4. 각 오버레이를 적용하여 staging에는 1개, prod에는 3개의 레플리카가 실행되도록 하세요:
   - `kubectl apply -k /tmp/kustomize/overlays/staging`
   - `kubectl apply -k /tmp/kustomize/overlays/prod`

## Expected Outcome

- `cka-q046-staging` 네임스페이스에 Deployment 1 replica Running
- `cka-q046-prod` 네임스페이스에 Deployment 3 replicas Running
- 두 환경 모두 Service가 존재

<details>
<summary>힌트 1</summary>

base `kustomization.yaml` 예시:
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- deployment.yaml
- service.yaml
```

</details>

<details>
<summary>힌트 2</summary>

overlay `kustomization.yaml`에서 replicas를 변경하려면:
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- ../../base
namespace: cka-q046-prod
replicas:
- name: kustom-app
  count: 3
```

</details>

<details>
<summary>힌트 3</summary>

적용 전 결과를 미리 확인하려면:
```bash
kubectl kustomize /tmp/kustomize/overlays/prod
```

</details>
