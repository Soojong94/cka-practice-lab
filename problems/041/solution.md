# Problem 041: 정답 풀이

## Step 1: DaemonSet 생성

```bash
kubectl -n cka-q041 apply -f - <<EOF
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: ds-important
  namespace: cka-q041
spec:
  selector:
    matchLabels:
      id: ds-important
  template:
    metadata:
      labels:
        id: ds-important
    spec:
      tolerations:
      - key: node-role.kubernetes.io/control-plane
        operator: Exists
        effect: NoSchedule
      containers:
      - name: httpd
        image: httpd:2-alpine
        resources:
          requests:
            cpu: "10m"
            memory: "10Mi"
EOF
```

## Step 2: 확인

```bash
# DaemonSet 상태 확인
kubectl -n cka-q041 get ds ds-important

# Pod가 모든 노드에서 실행 중인지 확인
kubectl -n cka-q041 get pods -o wide

# toleration 확인
kubectl -n cka-q041 get ds ds-important -o jsonpath='{.spec.template.spec.tolerations}'
```

## 핵심 개념

- DaemonSet은 모든 노드(또는 선택된 노드)에 Pod를 하나씩 배포
- Control Plane 노드에는 기본적으로 `node-role.kubernetes.io/control-plane:NoSchedule` taint가 있음
- 해당 taint를 tolerate해야 Control Plane에서도 Pod가 실행됨
- Docker Desktop 단일 노드 환경에서는 해당 노드가 Control Plane 역할도 수행
