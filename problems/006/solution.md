# Problem 006: 정답 풀이

## Step 1: ConfigMap 내용 확인

```bash
kubectl -n cka-q006 get configmap nginx-config -o yaml
```

## Step 2: Deployment에 ConfigMap 볼륨 마운트 추가

```bash
kubectl -n cka-q006 patch deployment web-server --type='json' -p='[
  {"op": "add", "path": "/spec/template/spec/volumes", "value": [{"name": "config-volume", "configMap": {"name": "nginx-config"}}]},
  {"op": "add", "path": "/spec/template/spec/containers/0/volumeMounts", "value": [{"name": "config-volume", "mountPath": "/etc/nginx/conf.d/"}]}
]'
```

또는 `kubectl -n cka-q006 edit deployment web-server`로 직접 편집:

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

## Step 3: Pod 재시작 확인

```bash
kubectl -n cka-q006 rollout status deployment/web-server
kubectl -n cka-q006 get pods -l app=web-server
```

## Step 4: 설정 파일 마운트 확인

```bash
POD=$(kubectl -n cka-q006 get pods -l app=web-server -o jsonpath='{.items[0].metadata.name}')
kubectl -n cka-q006 exec $POD -- ls /etc/nginx/conf.d/
kubectl -n cka-q006 exec $POD -- cat /etc/nginx/conf.d/custom.conf
```

## Step 5: nginx 응답 확인

```bash
kubectl -n cka-q006 exec $POD -- wget -qO- http://127.0.0.1
# 출력: Hello from CKA ConfigMap Lab!
```

## 검증

```bash
kubectl -n cka-q006 get deployment web-server -o yaml | grep -A5 volumeMounts
kubectl -n cka-q006 get deployment web-server -o yaml | grep -A5 volumes
```
