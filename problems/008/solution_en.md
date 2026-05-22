# Problem 008: Solution

## Step 1: Create Pod (initContainer + emptyDir)

```bash
kubectl -n cka-q008 apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: web-init
spec:
  initContainers:
  - name: init-download
    image: busybox:1.36
    command: ["sh", "-c", "echo '<html><body><h1>Init Container Demo</h1></body></html>' > /work-dir/index.html"]
    volumeMounts:
    - name: workdir
      mountPath: /work-dir
  containers:
  - name: nginx
    image: nginx:1.25-alpine
    ports:
    - containerPort: 80
    volumeMounts:
    - name: workdir
      mountPath: /usr/share/nginx/html
  volumes:
  - name: workdir
    emptyDir: {}
EOF
```

## Step 2: Verify Pod status

```bash
kubectl -n cka-q008 get pod web-init
# STATUS: Running, READY: 1/1

# Check initContainer status
kubectl -n cka-q008 get pod web-init -o jsonpath='{.status.initContainerStatuses[0].state}'
# {"terminated":{"exitCode":0,"reason":"Completed",...}}
```

## Step 3: Verify serving

```bash
kubectl -n cka-q008 exec web-init -c nginx -- wget -qO- http://localhost
# Output: <html><body><h1>Init Container Demo</h1></body></html>
```

## Verification

```bash
kubectl -n cka-q008 describe pod web-init
kubectl -n cka-q008 logs web-init -c init-download
```
