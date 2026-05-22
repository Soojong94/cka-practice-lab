# Problem 007: Mount Secret as Volume + Environment Variables

| Item | Value |
|------|-------|
| Problem # | 007 |
| Domain | Configuration |
| Difficulty | killer.sh Level |
| Estimated Time | 9 min |
| Namespace | cka-q007 |

## Context

In namespace `cka-q007`, database connection credentials need to be managed securely. A Pod named `db-app` is currently running but does not yet have any secrets attached.

You need to create a Secret with database credentials and expose them to the Pod using both a volume mount and environment variables.

> Note: You may refer to the official documentation at https://kubernetes.io/docs.

## Tasks

1. Create a Secret in namespace `cka-q007` with the following spec:
   - Name: `db-credentials`
   - Type: `Opaque`
   - Data:
     - `username`: `admin` (base64 encoded)
     - `password`: `s3cur3P@ss` (base64 encoded)

2. Delete the existing Pod `db-app` and create a new Pod with the following spec:
   - Name: `db-app`
   - Image: `busybox:1.36`
   - Command: `sleep 3600`
   - Mount Secret `db-credentials` as a volume at `/etc/secrets`

3. Configure environment variables on the same Pod:
   - `DB_USER`: sourced from Secret `db-credentials` key `username`
   - `DB_PASS`: sourced from Secret `db-credentials` key `password`

4. Verify that `/etc/secrets/username` inside the Pod contains `admin`.

5. Verify that environment variables `DB_USER` is `admin` and `DB_PASS` is `s3cur3P@ss` inside the Pod.

## Expected Outcome

- Secret `db-credentials` exists
- Pod `db-app` is in Running state
- `/etc/secrets/username` and `/etc/secrets/password` files exist
- Environment variables `DB_USER=admin`, `DB_PASS=s3cur3P@ss` are set

<details>
<summary>Hint 1</summary>

When creating a Secret with `kubectl create secret generic`, values are automatically base64 encoded:
```bash
kubectl -n cka-q007 create secret generic db-credentials --from-literal=username=admin --from-literal=password='s3cur3P@ss'
```

</details>

<details>
<summary>Hint 2</summary>

Pod spec with both volume mount and environment variables:
```yaml
spec:
  containers:
  - name: db-app
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
  volumes:
  - name: secret-vol
    secret:
      secretName: db-credentials
```

</details>

<details>
<summary>Hint 3</summary>

Verification commands:
```bash
kubectl -n cka-q007 exec db-app -- cat /etc/secrets/username
kubectl -n cka-q007 exec db-app -- env | grep DB_
```

</details>
