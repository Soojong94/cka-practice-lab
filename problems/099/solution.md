# Problem 099: 정답 풀이

## Step 1: Deployment에 Probe 추가

```bash
kubectl -n cka-q099 patch deployment probe-app --type='json' -p='[
  {"op": "add", "path": "/spec/template/spec/containers/0/livenessProbe", "value": {
    "httpGet": {"path": "/healthz", "port": 80},
    "periodSeconds": 10
  }},
  {"op": "add", "path": "/spec/template/spec/containers/0/readinessProbe", "value": {
    "httpGet": {"path": "/", "port": 80},
    "initialDelaySeconds": 5
  }},
  {"op": "add", "path": "/spec/template/spec/containers/0/startupProbe", "value": {
    "httpGet": {"path": "/", "port": 80},
    "failureThreshold": 30,
    "periodSeconds": 10
  }}
]'
```

또는 `kubectl -n cka-q099 edit deployment probe-app`으로 직접 편집:

```yaml
spec:
  template:
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
        livenessProbe:
          httpGet:
            path: /healthz
            port: 80
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
        startupProbe:
          httpGet:
            path: /
            port: 80
          failureThreshold: 30
          periodSeconds: 10
```

## 검증

```bash
kubectl -n cka-q099 describe deployment probe-app | grep -A5 "Liveness\|Readiness\|Startup"
kubectl -n cka-q099 get pods -l app=probe-app
```
