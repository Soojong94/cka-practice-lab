# Problem 058: 정답 풀이

## Step 1: ClusterRole 생성

```bash
kubectl create clusterrole node-viewer \
  --verb=get,list,watch \
  --resource=nodes,namespaces
```

## Step 2: ClusterRoleBinding 생성

```bash
kubectl create clusterrolebinding node-viewer-binding \
  --clusterrole=node-viewer \
  --serviceaccount=cka-q058:cluster-viewer
```

## Step 3: 권한 확인 및 ConfigMap 생성

```bash
# nodes list 권한 확인
CAN_LIST_NODES=$(kubectl auth can-i list nodes --as=system:serviceaccount:cka-q058:cluster-viewer)
echo $CAN_LIST_NODES  # yes

# namespaces list 권한 확인 (다른 네임스페이스에서)
CAN_LIST_NS=$(kubectl -n default auth can-i list namespaces --as=system:serviceaccount:cka-q058:cluster-viewer)
echo $CAN_LIST_NS  # yes

# pods delete 권한 확인
CAN_DELETE=$(kubectl auth can-i delete pods --as=system:serviceaccount:cka-q058:cluster-viewer)
echo $CAN_DELETE  # no

# ConfigMap 생성
kubectl -n cka-q058 create configmap cluster-rbac-verify \
  --from-literal=can-list-nodes="$CAN_LIST_NODES" \
  --from-literal=can-list-namespaces="$CAN_LIST_NS" \
  --from-literal=can-delete-pods="$CAN_DELETE"
```

## 검증

```bash
kubectl get clusterrole node-viewer -o yaml
kubectl get clusterrolebinding node-viewer-binding -o yaml
kubectl -n cka-q058 get configmap cluster-rbac-verify -o yaml
```
