# Problem 023: kube-proxy iptables 규칙 확인

| 항목 | 값 |
|------|-----|
| 문제 번호 | 023 |
| 도메인 | Troubleshooting |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 8분 |
| 네임스페이스 | cka-q023 |

## Context

네임스페이스 `cka-q023`에 `web-app` Deployment와 `web-svc` ClusterIP Service가 동작 중입니다. kube-proxy가 생성한 iptables 규칙을 분석하여 Service의 네트워크 동작을 이해해야 합니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. Service `web-svc`의 ClusterIP를 확인하세요.

2. Service `web-svc`의 Endpoints를 확인하세요 (Pod IP 목록).

3. 다음 스펙으로 ConfigMap을 생성하세요:
   - 이름: `kube-proxy-analysis`
   - 네임스페이스: `cka-q023`
   - 데이터:
     - `cluster-ip`: Service의 ClusterIP 주소
     - `service-port`: Service의 포트 번호
     - `endpoint-count`: Endpoint 수 (숫자)

4. ConfigMap에 `iptables-chain` 키를 추가하세요:
   - 값: `KUBE-SVC` (kube-proxy가 Service에 대해 생성하는 iptables 체인 접두사)

## Expected Outcome

- ConfigMap `kube-proxy-analysis`가 네임스페이스 `cka-q023`에 존재
- `cluster-ip` 값이 실제 Service ClusterIP와 일치
- `iptables-chain` 값이 `KUBE-SVC` 포함

<details>
<summary>힌트 1</summary>

Service의 ClusterIP 확인:
```bash
kubectl -n cka-q023 get svc web-svc -o jsonpath='{.spec.clusterIP}'
```

</details>

<details>
<summary>힌트 2</summary>

Endpoints 확인:
```bash
kubectl -n cka-q023 get endpoints web-svc
```

kube-proxy는 각 Service에 대해 `KUBE-SVC-*` 체인을 생성하고, 각 Endpoint에 대해 `KUBE-SEP-*` 체인을 생성합니다.

</details>

<details>
<summary>힌트 3</summary>

```bash
CLUSTER_IP=$(kubectl -n cka-q023 get svc web-svc -o jsonpath='{.spec.clusterIP}')
EP_COUNT=$(kubectl -n cka-q023 get endpoints web-svc -o jsonpath='{.subsets[0].addresses}' | jq length)

kubectl -n cka-q023 create configmap kube-proxy-analysis \
  --from-literal=cluster-ip="$CLUSTER_IP" \
  --from-literal=service-port="80" \
  --from-literal=endpoint-count="$EP_COUNT" \
  --from-literal=iptables-chain="KUBE-SVC"
```

</details>
