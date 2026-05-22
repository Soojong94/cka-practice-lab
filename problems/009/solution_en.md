# Problem 009: Solution

## Step 1: Verify existing resources

```bash
kubectl -n cka-q009 get sa app-sa
kubectl -n cka-q009 get configmap app-config -o yaml
kubectl -n cka-q009 get secret app-secret -o yaml
```

## Step 2: Create Pod with projected volume

```bash
kubectl -n cka-q009 apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: projected-pod
spec:
  serviceAccountName: app-sa
  containers:
  - name: app
    image: busybox:1.36
    command: ["sleep", "3600"]
    volumeMounts:
    - name: projected-vol
      mountPath: /etc/projected
  volumes:
  - name: projected-vol
    projected:
      sources:
      - serviceAccountToken:
          path: token
          expirationSeconds: 3600
      - configMap:
          name: app-config
          items:
          - key: app.properties
            path: config/app.properties
      - secret:
          name: app-secret
          items:
          - key: api-key
            path: secrets/api-key
EOF
```

## Step 3: Verify Pod status

```bash
kubectl -n cka-q009 get pod projected-pod
# STATUS: Running
```

## Step 4: Verify mounted files

```bash
# Check directory structure
kubectl -n cka-q009 exec projected-pod -- find /etc/projected -type f

# Verify ServiceAccount token
kubectl -n cka-q009 exec projected-pod -- cat /etc/projected/token

# Verify ConfigMap
kubectl -n cka-q009 exec projected-pod -- cat /etc/projected/config/app.properties
# Output:
# app.name=projected-demo
# app.version=1.0.0
# app.env=production

# Verify Secret
kubectl -n cka-q009 exec projected-pod -- cat /etc/projected/secrets/api-key
# Output: k8s-projected-secret-key-2024
```

## Verification

```bash
kubectl -n cka-q009 describe pod projected-pod | grep -A20 Volumes
```
