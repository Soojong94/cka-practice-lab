# Problem 040: 정답 풀이

## Step 1: 이벤트 확인

```bash
kubectl -n cka-q040 get events --sort-by='.lastTimestamp'
```

## Step 2: 실패 Pod 원인 분석

```bash
kubectl -n cka-q040 describe pod failing-pod
# Events:
#   Warning  Failed     ... Error: ErrImagePull
#   Warning  BackOff    ... Back-off pulling image "nginx:nonexistent-tag-12345"
```

## Step 3: 스크립트 파일 생성

```bash
cat > /tmp/cka-q040-events.sh << 'EOF'
#!/bin/bash
# CKA Q040: Event 분석 스크립트

NAMESPACE="cka-q040"

# 1. 네임스페이스의 모든 이벤트를 시간순으로 조회
echo "=== 모든 이벤트 (시간순) ==="
kubectl -n $NAMESPACE get events --sort-by='.lastTimestamp'

# 2. Warning 타입 이벤트만 필터링
echo ""
echo "=== Warning 이벤트 ==="
kubectl -n $NAMESPACE get events --field-selector type=Warning

# 3. 특정 Pod(failing-pod)의 이벤트 조회
echo ""
echo "=== failing-pod 이벤트 ==="
kubectl -n $NAMESPACE get events --field-selector involvedObject.name=failing-pod
EOF

chmod +x /tmp/cka-q040-events.sh
```

## Step 4: ConfigMap 생성

```bash
kubectl -n cka-q040 create configmap event-analysis \
  --from-literal=failing-pod-reason=ImagePullBackOff
```

## 검증

```bash
ls -la /tmp/cka-q040-events.sh
cat /tmp/cka-q040-events.sh
kubectl -n cka-q040 get configmap event-analysis -o yaml
```
