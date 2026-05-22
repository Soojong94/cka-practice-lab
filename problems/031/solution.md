# Problem 031: 정답 풀이

## Step 1: 현재 권한 확인

```bash
kubectl auth can-i --list --as=system:serviceaccount:cka-q031:app-sa -n cka-q031
kubectl auth can-i list pods --as=system:serviceaccount:cka-q031:app-sa -n cka-q031
kubectl auth can-i create configmaps --as=system:serviceaccount:cka-q031:app-sa -n cka-q031
```

## Step 2: Role 수정

```bash
kubectl -n cka-q031 apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: app-role
  namespace: cka-q031
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
- apiGroups: [""]
  resources: ["configmaps"]
  verbs: ["create"]
EOF
```

또는 `kubectl -n cka-q031 edit role app-role`로 직접 편집합니다.

## Step 3: 권한 확인

```bash
kubectl auth can-i list pods --as=system:serviceaccount:cka-q031:app-sa -n cka-q031
# yes

kubectl auth can-i create configmaps --as=system:serviceaccount:cka-q031:app-sa -n cka-q031
# yes

kubectl auth can-i get pods --as=system:serviceaccount:cka-q031:app-sa -n cka-q031
# yes
```

## Step 4: RoleBinding 확인

```bash
kubectl -n cka-q031 get rolebinding app-rolebinding -o yaml
```

## 검증

```bash
kubectl auth can-i list pods --as=system:serviceaccount:cka-q031:app-sa -n cka-q031
kubectl auth can-i create configmaps --as=system:serviceaccount:cka-q031:app-sa -n cka-q031
```
