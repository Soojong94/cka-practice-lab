# Problem 009: Projected Volume (Combining Multiple Sources)

| Item | Value |
|------|-------|
| Problem # | 009 |
| Domain | Configuration |
| Difficulty | killer.sh Level |
| Estimated Time | 12 min |
| Namespace | cka-q009 |

## Context

In namespace `cka-q009`, a ServiceAccount `app-sa`, ConfigMap `app-config`, and Secret `app-secret` already exist.

The application needs to access multiple configuration sources from a single directory. Use a projected volume to combine these three sources into one mount point.

> Note: You may refer to the official documentation at https://kubernetes.io/docs.

## Tasks

1. Verify the following resources exist in namespace `cka-q009`:
   - ServiceAccount: `app-sa`
   - ConfigMap: `app-config` (key: `app.properties`)
   - Secret: `app-secret` (key: `api-key`)

2. Create a Pod with the following spec:
   - Name: `projected-pod`
   - Image: `busybox:1.36`
   - Command: `sleep 3600`
   - ServiceAccount: `app-sa`

3. Configure a projected volume mounted at `/etc/projected` with the following sources:
   - ServiceAccount token (path: `token`, expirationSeconds: 3600)
   - ConfigMap `app-config` (items: `app.properties` → path: `config/app.properties`)
   - Secret `app-secret` (items: `api-key` → path: `secrets/api-key`)

4. Verify that `/etc/projected/token` file exists inside the Pod.

5. Verify the contents of `/etc/projected/config/app.properties` and `/etc/projected/secrets/api-key` inside the Pod.

## Expected Outcome

- Pod `projected-pod` is in Running state
- `/etc/projected/token` file exists (ServiceAccount token)
- `/etc/projected/config/app.properties` contains ConfigMap content
- `/etc/projected/secrets/api-key` contains Secret content

<details>
<summary>Hint 1</summary>

A projected volume combines multiple volume sources into a single directory. Define `serviceAccountToken`, `configMap`, and `secret` sources within a single projected volume.

</details>

<details>
<summary>Hint 2</summary>

```yaml
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
```

</details>

<details>
<summary>Hint 3</summary>

Verification commands:
```bash
kubectl -n cka-q009 exec projected-pod -- ls -la /etc/projected/
kubectl -n cka-q009 exec projected-pod -- cat /etc/projected/config/app.properties
kubectl -n cka-q009 exec projected-pod -- cat /etc/projected/secrets/api-key
```

</details>
