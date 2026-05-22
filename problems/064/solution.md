# Problem 064: 정답 풀이

## Step 1: CRD 생성

```bash
kubectl apply -f - <<EOF
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: databases.stable.example.com
spec:
  group: stable.example.com
  versions:
  - name: v1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            properties:
              databaseName:
                type: string
              version:
                type: string
              replicas:
                type: integer
  scope: Namespaced
  names:
    plural: databases
    singular: database
    kind: Database
    shortNames:
    - db
EOF
```

## Step 2: CRD 등록 확인

```bash
kubectl get crd databases.stable.example.com
kubectl api-resources | grep databases
```

## Step 3: Custom Resource 생성

```bash
kubectl -n cka-q064 apply -f - <<EOF
apiVersion: stable.example.com/v1
kind: Database
metadata:
  name: my-postgres
  namespace: cka-q064
spec:
  databaseName: postgres
  version: "15.4"
  replicas: 3
EOF
```

## Step 4: CR 조회

```bash
kubectl -n cka-q064 get databases
kubectl -n cka-q064 get database my-postgres -o yaml
```

## 검증

```bash
kubectl get crd databases.stable.example.com -o jsonpath='{.spec.scope}'
kubectl -n cka-q064 get database my-postgres -o jsonpath='{.spec}'
```
