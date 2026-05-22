# Problem 029: 정답 풀이

## Step 1: Service CIDR 확인

```bash
kubectl -n cka-q029 get configmap apiserver-manifest -o jsonpath='{.data.kube-apiserver\.yaml}' | grep service-cluster-ip-range
# 출력: - --service-cluster-ip-range=10.96.0.0/12
```

## Step 2: Service ClusterIP 확인

```bash
kubectl -n cka-q029 get svc test-svc -o jsonpath='{.spec.clusterIP}'
# 예: 10.96.xxx.xxx (10.96.0.0/12 범위 내)
```

## Step 3: CIDR 범위 확인

`10.96.0.0/12`의 범위:
- 시작: 10.96.0.0
- 끝: 10.111.255.255
- Service ClusterIP가 이 범위 내에 있으므로 "true"

## Step 4: ConfigMap 생성

```bash
SVC_IP=$(kubectl -n cka-q029 get svc test-svc -o jsonpath='{.spec.clusterIP}')

kubectl -n cka-q029 create configmap service-cidr-answer \
  --from-literal=service-cidr="10.96.0.0/12" \
  --from-literal=test-svc-ip="$SVC_IP" \
  --from-literal=in-range="true" \
  --from-literal=manifest-path="/etc/kubernetes/manifests/kube-apiserver.yaml"
```

## 참고: Service CIDR 변경 시 주의사항

실제 환경에서 Service CIDR을 변경하려면:
1. kube-apiserver manifest 수정: `/etc/kubernetes/manifests/kube-apiserver.yaml`
2. kube-controller-manager manifest 수정 (동일한 CIDR 설정)
3. 기존 Service는 재생성 필요 (IP가 변경됨)
4. kube-proxy 설정 업데이트

## 검증

```bash
kubectl -n cka-q029 get configmap service-cidr-answer -o yaml
```
