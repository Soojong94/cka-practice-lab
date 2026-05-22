# Problem 007: Solution

## Step 1: Create Secret

```bash
kubectl -n cka-q007 create secret generic db-credentials \
  --from-literal=username=admin \
  --from-literal=password='s3cur3P@ss'
```

## Step 2: Delete existing Pod

```bash
kubectl -n cka-q007 delete pod db-app
```

## Step 3: Create Pod with Secret as volume + environment variables

```bash
kubectl -n cka-q007 apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: db-app
  labels:
    app: db-app
spec:
  containers:
  - name: db-app
    image: busybox:1.36
    command: ["sleep", "3600"]
    env:
    - name: DB_USER
      valueFrom:
        secretKeyRef:
          name: db-credentials
          key: username
    - name: DB_PASS
      valueFrom:
        secretKeyRef:
          name: db-credentials
          key: password
    volumeMounts:
    - name: secret-vol
      mountPath: /etc/secrets
      readOnly: true
  volumes:
  - name: secret-vol
    secret:
      secretName: db-credentials
EOF
```

## Step 4: Verification

```bash
# Check Pod status
kubectl -n cka-q007 get pod db-app

# Verify volume mount
kubectl -n cka-q007 exec db-app -- cat /etc/secrets/username
# Output: admin

kubectl -n cka-q007 exec db-app -- cat /etc/secrets/password
# Output: s3cur3P@ss

# Verify environment variables
kubectl -n cka-q007 exec db-app -- env | grep DB_
# Output:
# DB_USER=admin
# DB_PASS=s3cur3P@ss
```
