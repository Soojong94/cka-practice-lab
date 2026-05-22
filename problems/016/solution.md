# Problem 016: 정답 풀이

## Step 1: 잘못된 매니페스트 확인

```bash
kubectl -n cka-q016 get configmap scheduler-broken-manifest -o jsonpath='{.data.manifest}'
```

세 개의 플래그에서 잘못된 경로를 확인할 수 있습니다:
- `--kubeconfig=/etc/kubernetes/scheduler-wrong.conf`
- `--authentication-kubeconfig=/etc/kubernetes/scheduler-wrong.conf`
- `--authorization-kubeconfig=/etc/kubernetes/scheduler-wrong.conf`

## Step 2: 에러 로그 확인

```bash
kubectl -n cka-q016 get configmap scheduler-broken-manifest -o jsonpath='{.data.error-log}'
```

`open /etc/kubernetes/scheduler-wrong.conf: no such file or directory` 에러를 확인합니다.

## Step 3: 수정된 매니페스트로 ConfigMap 생성

```bash
kubectl -n cka-q016 get configmap scheduler-broken-manifest -o jsonpath='{.data.manifest}' | \
  sed 's/scheduler-wrong.conf/scheduler.conf/g' > /tmp/scheduler-fixed.yaml

kubectl -n cka-q016 create configmap scheduler-fixed-manifest \
  --from-file=manifest=/tmp/scheduler-fixed.yaml
```

## 실제 환경에서의 복구 절차

```bash
# 1. static pod 매니페스트 수정
vi /etc/kubernetes/manifests/kube-scheduler.yaml

# 2. scheduler-wrong.conf → scheduler.conf 로 수정
# 3. kubelet이 자동으로 static pod를 재시작함
# 4. 확인
kubectl get pods -n kube-system | grep scheduler
```

## 검증

```bash
kubectl -n cka-q016 get configmap scheduler-fixed-manifest -o yaml
```
