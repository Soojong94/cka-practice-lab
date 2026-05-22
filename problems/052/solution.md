# Problem 052: 정답 풀이

## Step 1: Multi-container Pod 생성

```bash
kubectl -n cka-q052 apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: app-with-sidecar
  namespace: cka-q052
spec:
  volumes:
  - name: shared-logs
    emptyDir: {}
  containers:
  - name: main-app
    image: nginx:1-alpine
    volumeMounts:
    - name: shared-logs
      mountPath: /usr/share/nginx/html
  - name: sidecar
    image: busybox
    command: ["/bin/sh", "-c", "while true; do date >> /var/log/app/index.html; sleep 1; done"]
    volumeMounts:
    - name: shared-logs
      mountPath: /var/log/app
EOF
```

## Step 2: 확인

```bash
# Pod 상태 확인 (2/2 Ready)
kubectl -n cka-q052 get pod app-with-sidecar

# 사이드카 로그 확인
kubectl -n cka-q052 exec app-with-sidecar -c main-app -- cat /usr/share/nginx/html/index.html

# 또는 사이드카 컨테이너에서 직접 확인
kubectl -n cka-q052 exec app-with-sidecar -c sidecar -- cat /var/log/app/index.html
```

## 핵심 개념

- Sidecar 패턴: 메인 컨테이너를 보조하는 컨테이너 (로깅, 프록시, 모니터링 등)
- emptyDir: Pod 수명과 동일한 임시 볼륨 (컨테이너 간 데이터 공유)
- 같은 Pod 내 컨테이너는 네트워크(localhost)와 볼륨을 공유
- `-c <container-name>`: 특정 컨테이너에서 명령 실행
- 다른 Multi-container 패턴: Ambassador, Adapter
