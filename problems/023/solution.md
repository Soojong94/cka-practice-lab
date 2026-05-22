# Problem 023: 정답 풀이

## Step 1: Service ClusterIP 확인

```bash
kubectl -n cka-q023 get svc web-svc -o jsonpath='{.spec.clusterIP}'
# 예: 10.96.xxx.xxx
```

## Step 2: Endpoints 확인

```bash
kubectl -n cka-q023 get endpoints web-svc
# 2개의 Pod IP가 표시됨
```

## Step 3: ConfigMap 생성

```bash
CLUSTER_IP=$(kubectl -n cka-q023 get svc web-svc -o jsonpath='{.spec.clusterIP}')

kubectl -n cka-q023 create configmap kube-proxy-analysis \
  --from-literal=cluster-ip="$CLUSTER_IP" \
  --from-literal=service-port="80" \
  --from-literal=endpoint-count="2" \
  --from-literal=iptables-chain="KUBE-SVC"
```

## 참고: kube-proxy iptables 체인 구조

kube-proxy는 다음과 같은 iptables 체인을 생성합니다:

1. **KUBE-SERVICES**: 모든 Service의 진입점
2. **KUBE-SVC-\***: 각 Service에 대한 체인 (로드밸런싱)
3. **KUBE-SEP-\***: 각 Service Endpoint에 대한 체인 (DNAT)

```bash
# iptables 규칙 확인 (노드에서 실행)
iptables -t nat -L KUBE-SERVICES | grep web-svc
```

## 검증

```bash
kubectl -n cka-q023 get configmap kube-proxy-analysis -o yaml
```
