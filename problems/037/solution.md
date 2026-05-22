# Problem 037: 정답 풀이

## Step 1: 컨트롤플레인 Pod 확인

```bash
kubectl -n kube-system get pods -o wide
```

Docker Desktop 환경에서 일반적인 결과:
- `kube-apiserver-docker-desktop` → static-pod
- `etcd-docker-desktop` → static-pod
- `kube-scheduler-docker-desktop` → static-pod
- `kube-controller-manager-docker-desktop` → static-pod
- `coredns-*` → deployment

## Step 2: 이미지 확인

```bash
# kube-apiserver
kubectl -n kube-system get pod kube-apiserver-docker-desktop -o jsonpath='{.spec.containers[0].image}'

# etcd
kubectl -n kube-system get pod etcd-docker-desktop -o jsonpath='{.spec.containers[0].image}'

# kube-scheduler
kubectl -n kube-system get pod kube-scheduler-docker-desktop -o jsonpath='{.spec.containers[0].image}'

# kube-controller-manager
kubectl -n kube-system get pod kube-controller-manager-docker-desktop -o jsonpath='{.spec.containers[0].image}'

# coredns
kubectl -n kube-system get pods -l k8s-app=kube-dns -o jsonpath='{.items[0].spec.containers[0].image}'
```

## Step 3: 노드 확인

```bash
NODE_NAME=$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')
echo $NODE_NAME
# docker-desktop
```

## Step 4: ConfigMap 업데이트

```bash
# 변수 수집
NODE=$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')
API_IMG=$(kubectl -n kube-system get pod kube-apiserver-${NODE} -o jsonpath='{.spec.containers[0].image}')
ETCD_IMG=$(kubectl -n kube-system get pod etcd-${NODE} -o jsonpath='{.spec.containers[0].image}')
SCHED_IMG=$(kubectl -n kube-system get pod kube-scheduler-${NODE} -o jsonpath='{.spec.containers[0].image}')
CM_IMG=$(kubectl -n kube-system get pod kube-controller-manager-${NODE} -o jsonpath='{.spec.containers[0].image}')
DNS_IMG=$(kubectl -n kube-system get pods -l k8s-app=kube-dns -o jsonpath='{.items[0].spec.containers[0].image}')
DNS_NODE=$(kubectl -n kube-system get pods -l k8s-app=kube-dns -o jsonpath='{.items[0].spec.nodeName}')

# ConfigMap 업데이트
kubectl -n cka-q037 patch configmap cluster-info --type merge -p "{\"data\": {
  \"kube-apiserver-type\": \"static-pod\",
  \"kube-apiserver-node\": \"${NODE}\",
  \"kube-apiserver-image\": \"${API_IMG}\",
  \"etcd-type\": \"static-pod\",
  \"etcd-node\": \"${NODE}\",
  \"etcd-image\": \"${ETCD_IMG}\",
  \"kube-scheduler-type\": \"static-pod\",
  \"kube-scheduler-node\": \"${NODE}\",
  \"kube-scheduler-image\": \"${SCHED_IMG}\",
  \"kube-controller-manager-type\": \"static-pod\",
  \"kube-controller-manager-node\": \"${NODE}\",
  \"kube-controller-manager-image\": \"${CM_IMG}\",
  \"coredns-type\": \"deployment\",
  \"coredns-node\": \"${DNS_NODE}\",
  \"coredns-image\": \"${DNS_IMG}\"
}}"
```

## 검증

```bash
kubectl -n cka-q037 get configmap cluster-info -o yaml
```
