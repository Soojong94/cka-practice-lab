# Problem 006: Solution

## Step 1: Inspect ConfigMap contents

```bash
kubectl -n cka-q006 get configmap nginx-config -o yaml
```

## Step 2: Add ConfigMap volume mount to Deployment

```bash
kubectl -n cka-q006 patch deployment web-server --type='json' -p='[
  {"op": "add", "path": "/spec/template/spec/volumes", "value": [{"name": "config-volume", "configMap": {"name": "nginx-config"}}]},
  {"op": "add", "path": "/spec/template/spec/containers/0/volumeMounts", "value": [{"name": "config-volume", "mountPath": "/etc/nginx/conf.d/"}]}
]'
```

Or edit directly with `kubectl -n cka-q006 edit deployment web-server`:

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
        image: nginx:1.25-alpine
        ports:
        - containerPort: 80
        volumeMounts:
        - name: config-volume
          mountPath: /etc/nginx/conf.d/
```

## Step 3: Verify Pod restart

```bash
kubectl -n cka-q006 rollout status deployment/web-server
kubectl -n cka-q006 get pods -l app=web-server
```

## Step 4: Verify config file is mounted

```bash
POD=$(kubectl -n cka-q006 get pods -l app=web-server -o jsonpath='{.items[0].metadata.name}')
kubectl -n cka-q006 exec $POD -- ls /etc/nginx/conf.d/
kubectl -n cka-q006 exec $POD -- cat /etc/nginx/conf.d/custom.conf
```

## Step 5: Verify nginx response

```bash
kubectl -n cka-q006 exec $POD -- wget -qO- http://localhost
# Output: Hello from CKA ConfigMap Lab!
```

## Verification

```bash
kubectl -n cka-q006 get deployment web-server -o yaml | grep -A5 volumeMounts
kubectl -n cka-q006 get deployment web-server -o yaml | grep -A5 volumes
```
