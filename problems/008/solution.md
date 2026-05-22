# Problem 008: 정답 풀이

## Step 1: Pod 생성 (initContainer + emptyDir)

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

## Step 2: Pod 상태 확인

```bash
kubectl -n cka-q008 get pod web-init
# STATUS: Running, READY: 1/1

# initContainer 상태 확인
kubectl -n cka-q008 get pod web-init -o jsonpath='{.status.initContainerStatuses[0].state}'
# {"terminated":{"exitCode":0,"reason":"Completed",...}}
```

## Step 3: 서빙 확인

```bash
kubectl -n cka-q008 exec web-init -c nginx -- wget -qO- http://localhost
# 출력: <html><body><h1>Init Container Demo</h1></body></html>
```

## 검증

```bash
kubectl -n cka-q008 describe pod web-init
kubectl -n cka-q008 logs web-init -c init-download
```
