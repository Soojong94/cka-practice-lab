# Problem 034: 정답 풀이

## Step 1: HPA 상태 확인

```bash
kubectl -n cka-q034 get hpa web-hpa
# TARGETS: <unknown>/50%
```

## Step 2: HPA 상세 확인

```bash
kubectl -n cka-q034 describe hpa web-hpa
# Events에 "missing request for cpu" 메시지 확인
```

## Step 3: Deployment에 resource requests 추가

```bash
kubectl -n cka-q034 patch deployment web-deploy --type='json' -p='[
  {"op": "add", "path": "/spec/template/spec/containers/0/resources", "value": {"requests": {"cpu": "50m"}, "limits": {"cpu": "200m"}}}
]'
```

또는 `kubectl -n cka-q034 edit deployment web-deploy`로 직접 편집:

```yaml
spec:
  template:
    spec:
      containers:
      - name: nginx
        image: nginx:1.24-alpine
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: "50m"
          limits:
            cpu: "200m"
```

## Step 4: HPA 상태 재확인

```bash
kubectl -n cka-q034 get hpa web-hpa
# TARGETS에 실제 값이 표시됨 (예: 0%/50% 또는 1%/50%)
```

## 검증

```bash
kubectl -n cka-q034 get deployment web-deploy -o jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu}'
# 50m
```
