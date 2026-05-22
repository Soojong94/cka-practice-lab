# Problem 006: Mount ConfigMap as Volume

| Item | Value |
|------|-------|
| Problem # | 006 |
| Domain | Configuration |
| Difficulty | killer.sh Level |
| Estimated Time | 8 min |
| Namespace | cka-q006 |

## Context

In namespace `cka-q006`, a Deployment named `web-server` (nginx) is running. A ConfigMap named `nginx-config` already exists and contains a custom nginx configuration file (`custom.conf`).

Currently nginx is running with default configuration, and the ConfigMap settings need to be applied.

> Note: You may refer to the official documentation at https://kubernetes.io/docs.

## Tasks

1. Inspect the contents of ConfigMap `nginx-config`.
   - It should contain an nginx server configuration under the `custom.conf` key.

2. Modify Deployment `web-server` to mount ConfigMap `nginx-config` as a volume:
   - Mount path: `/etc/nginx/conf.d/`
   - Volume name: `config-volume`

3. Verify that the Deployment's Pod has restarted and the new configuration is applied.

4. Verify that nginx responds with the custom configuration:
   - Running `curl localhost` inside the Pod should return `Hello from CKA ConfigMap Lab!`

5. Verify that the ConfigMap is mounted as `/etc/nginx/conf.d/custom.conf`.

## Expected Outcome

- Deployment `web-server` has the ConfigMap volume mounted
- `/etc/nginx/conf.d/custom.conf` file exists
- nginx responds with `Hello from CKA ConfigMap Lab!`

<details>
<summary>Hint 1</summary>

When a ConfigMap is mounted as a volume, each key becomes a filename and its value becomes the file content. The `custom.conf` key will be mounted as `/etc/nginx/conf.d/custom.conf`.

</details>

<details>
<summary>Hint 2</summary>

```yaml
spec:
  template:
    spec:
      volumes:
      - name: config-volume
        configMap:
          name: nginx-config
      containers:
      - name: nginx
        volumeMounts:
        - name: config-volume
          mountPath: /etc/nginx/conf.d/
```

</details>

<details>
<summary>Hint 3</summary>

Edit directly with `kubectl -n cka-q006 edit deployment web-server` or use the patch command. The Pod will automatically restart after the change.

The default nginx image does not include curl, so use `wget -qO- localhost` or test from a separate Pod.

</details>
