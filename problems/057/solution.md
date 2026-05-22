# Problem 057: 정답 풀이

## Step 1: Role 생성

```bash
kubectl -n cka-q057 create role developer-role \
  --verb=get,list,watch \
  --resource=pods,configmaps
```

## Step 2: RoleBinding 생성

```bash
kubectl -n cka-q057 create rolebinding developer-binding \
  --role=developer-role \
  --serviceaccount=cka-q057:developer
```

## Step 3: auth can-i 확인 및 ConfigMap 생성

```bash
# pods list 권한 확인
CAN_LIST=$(kubectl -n cka-q057 auth can-i list pods --as=system:serviceaccount:cka-q057:developer)
echo $CAN_LIST  # yes

# pods delete 권한 확인
CAN_DELETE=$(kubectl -n cka-q057 auth can-i delete pods --as=system:serviceaccount:cka-q057:developer)
echo $CAN_DELETE  # no

# ConfigMap 생성
kubectl -n cka-q057 create configmap rbac-verify \
  --from-literal=can-list-pods="$CAN_LIST" \
  --from-literal=can-delete-pods="$CAN_DELETE"
```

## 검증

```bash
kubectl -n cka-q057 get role developer-role -o yaml
kubectl -n cka-q057 get rolebinding developer-binding -o yaml
kubectl -n cka-q057 get configmap rbac-verify -o yaml
```
