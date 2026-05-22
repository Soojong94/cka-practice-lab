# Problem 008: emptyDir and initContainer

| Item | Value |
|------|-------|
| Problem # | 008 |
| Domain | Workloads |
| Difficulty | killer.sh Level |
| Estimated Time | 10 min |
| Namespace | cka-q008 |

## Context

Namespace `cka-q008` is empty. A web server needs to be deployed, but initial data must be downloaded and prepared before the server starts.

Use an initContainer to prepare the initial data and share it with the main container through an emptyDir volume.

> Note: You may refer to the official documentation at https://kubernetes.io/docs.

## Tasks

1. Create a Pod in namespace `cka-q008` with the following spec:
   - Name: `web-init`
   - emptyDir volume name: `workdir`

2. Configure the initContainer:
   - Name: `init-download`
   - Image: `busybox:1.36`
   - Command: `sh -c "echo '<html><body><h1>Init Container Demo</h1></body></html>' > /work-dir/index.html"`
   - Mount the emptyDir volume at `/work-dir`

3. Configure the main container:
   - Name: `nginx`
   - Image: `nginx:1.25-alpine`
   - Mount the emptyDir volume at `/usr/share/nginx/html`

4. Verify that the Pod is in Running state and the initContainer has Completed.

5. Verify that running `curl localhost` in the main container returns a response containing `Init Container Demo`.

## Expected Outcome

- Pod `web-init` is in Running state
- initContainer `init-download` is in Completed state
- nginx serves the `index.html` created by the initContainer

<details>
<summary>Hint 1</summary>

An emptyDir volume starts as an empty directory when the Pod is created and can be shared by all containers in the Pod. The initContainer runs first to prepare data, then the main container uses it.

</details>

<details>
<summary>Hint 2</summary>

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: web-init
spec:
  initContainers:
  - name: init-download
    image: busybox:1.36
    command: ["sh", "-c", "echo '<html>...</html>' > /work-dir/index.html"]
    volumeMounts:
    - name: workdir
      mountPath: /work-dir
  containers:
  - name: nginx
    image: nginx:1.25-alpine
    volumeMounts:
    - name: workdir
      mountPath: /usr/share/nginx/html
  volumes:
  - name: workdir
    emptyDir: {}
```

</details>

<details>
<summary>Hint 3</summary>

Check initContainer status:
```bash
kubectl -n cka-q008 get pod web-init -o jsonpath='{.status.initContainerStatuses[0].state}'
```

Verify nginx response:
```bash
kubectl -n cka-q008 exec web-init -- wget -qO- http://localhost
```

</details>
