# Problem 045: 정답 풀이

## Step 1: Pod static-web 생성

```bash
kubectl -n cka-q045 apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: static-web
  namespace: cka-q045
  labels:
    role: static-web
spec:
  containers:
  - name: nginx
    image: nginx:1-alpine
    ports:
    - containerPort: 80
EOF
```

## Step 2: ConfigMap에 매니페스트 저장

```bash
kubectl -n cka-q045 create configmap static-pod-manifest --from-literal=static-web.yaml='
apiVersion: v1
kind: Pod
metadata:
  name: static-web
  labels:
    role: static-web
spec:
  containers:
  - name: nginx
    image: nginx:1-alpine
    ports:
    - containerPort: 80
'
```

## Step 3: NodePort Service 생성

```bash
kubectl -n cka-q045 apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: static-web-svc
  namespace: cka-q045
spec:
  type: NodePort
  selector:
    role: static-web
  ports:
  - port: 80
    targetPort: 80
EOF
```

## Step 4: 확인

```bash
kubectl -n cka-q045 get pods
kubectl -n cka-q045 get svc static-web-svc
kubectl -n cka-q045 get endpoints static-web-svc
```

## 핵심 개념

- Static Pod: kubelet이 직접 관리하는 Pod (/etc/kubernetes/manifests/ 디렉토리)
- Static Pod는 API 서버를 통하지 않고 kubelet이 직접 생성/관리
- 실제 CKA 시험에서는 SSH로 노드에 접속하여 매니페스트 파일을 작성
- Docker Desktop에서는 컨테이너 내부 접근이 제한적이므로 시뮬레이션으로 대체
