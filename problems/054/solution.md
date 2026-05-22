# Problem 054: 정답 풀이

## Step 1: 현재 상태 확인

```bash
kubectl -n cka-q054 get statefulset web
kubectl -n cka-q054 get pods -l app=web
# web-0, web-1, web-2 확인
```

## Step 2: 1개로 스케일 다운

```bash
kubectl -n cka-q054 scale statefulset web --replicas=1
```

```bash
# 순서대로 삭제되는 것 확인 (web-2 → web-1)
kubectl -n cka-q054 get pods -l app=web -w
```

## Step 3: 2개로 스케일 업

```bash
kubectl -n cka-q054 scale statefulset web --replicas=2
```

## Step 4: 확인

```bash
# StatefulSet 상태 확인
kubectl -n cka-q054 get statefulset web

# Pod 확인 (web-0, web-1)
kubectl -n cka-q054 get pods -l app=web

# rollout 상태 확인
kubectl -n cka-q054 rollout status statefulset/web
```

## 핵심 개념

- StatefulSet: 상태를 가진 애플리케이션을 위한 워크로드 리소스
- Pod 이름이 고정됨 (web-0, web-1, web-2...)
- 순서대로 생성/삭제 (Ordered, Graceful)
- Headless Service 필요 (clusterIP: None)
- 각 Pod에 안정적인 네트워크 ID 제공 (web-0.web-headless.cka-q054.svc.cluster.local)
- PVC도 Pod별로 유지됨 (스케일 다운 후 다시 업하면 같은 PVC 사용)
