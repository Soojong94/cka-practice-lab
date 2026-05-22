# Problem 046: 정답 풀이

## Step 1: Base 매니페스트 작성

```bash
# deployment.yaml
cat > /tmp/kustomize/base/deployment.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kustom-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: kustom-app
  template:
    metadata:
      labels:
        app: kustom-app
    spec:
      containers:
      - name: nginx
        image: nginx:1-alpine
        ports:
        - containerPort: 80
EOF

# service.yaml
cat > /tmp/kustomize/base/service.yaml <<EOF
apiVersion: v1
kind: Service
metadata:
  name: kustom-app-svc
spec:
  selector:
    app: kustom-app
  ports:
  - port: 80
    targetPort: 80
EOF

# kustomization.yaml
cat > /tmp/kustomize/base/kustomization.yaml <<EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- deployment.yaml
- service.yaml
EOF
```

## Step 2: Staging 오버레이 작성

```bash
cat > /tmp/kustomize/overlays/staging/kustomization.yaml <<EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- ../../base
namespace: cka-q046-staging
EOF
```

## Step 3: Prod 오버레이 작성

```bash
cat > /tmp/kustomize/overlays/prod/kustomization.yaml <<EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- ../../base
namespace: cka-q046-prod
replicas:
- name: kustom-app
  count: 3
EOF
```

## Step 4: 적용

```bash
kubectl apply -k /tmp/kustomize/overlays/staging
kubectl apply -k /tmp/kustomize/overlays/prod
```

## Step 5: 확인

```bash
kubectl -n cka-q046-staging get deployment,svc
kubectl -n cka-q046-prod get deployment,svc
```

## 핵심 개념

- Kustomize: kubectl에 내장된 설정 관리 도구
- Base: 공통 매니페스트 정의
- Overlay: 환경별 차이점만 정의 (replicas, namespace, labels 등)
- `kubectl apply -k <dir>`: kustomization.yaml이 있는 디렉토리를 적용
- `kubectl kustomize <dir>`: 적용 전 결과를 미리 확인
