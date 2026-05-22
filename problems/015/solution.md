# Problem 015: 정답 풀이

## Step 1: 잘못된 매니페스트 확인

```bash
kubectl -n cka-q015 get configmap apiserver-broken-manifest -o jsonpath='{.data.manifest}'
```

`--etcd-servers=https://127.0.0.1:1234` 부분이 잘못되어 있습니다. etcd의 기본 클라이언트 포트는 2379입니다.

## Step 2: 에러 로그 확인

```bash
kubectl -n cka-q015 get configmap apiserver-broken-manifest -o jsonpath='{.data.error-log}'
```

`dial tcp 127.0.0.1:1234: connect: connection refused` 에러를 확인할 수 있습니다.

## Step 3: 수정된 매니페스트로 ConfigMap 생성

```bash
# 매니페스트 추출 및 수정
kubectl -n cka-q015 get configmap apiserver-broken-manifest -o jsonpath='{.data.manifest}' | \
  sed 's/etcd-servers=https:\/\/127.0.0.1:1234/etcd-servers=https:\/\/127.0.0.1:2379/' > /tmp/apiserver-fixed.yaml

# 수정된 ConfigMap 생성
kubectl -n cka-q015 create configmap apiserver-fixed-manifest \
  --from-file=manifest=/tmp/apiserver-fixed.yaml \
  --from-literal=etcd-endpoint="https://127.0.0.1:2379"
```

## 실제 환경에서의 복구 절차

```bash
# 1. static pod 매니페스트 위치
vi /etc/kubernetes/manifests/kube-apiserver.yaml

# 2. --etcd-servers 플래그 수정
# --etcd-servers=https://127.0.0.1:1234 → --etcd-servers=https://127.0.0.1:2379

# 3. kubelet이 자동으로 static pod를 재시작함
# 4. 확인
kubectl get pods -n kube-system | grep apiserver
```

## 검증

```bash
kubectl -n cka-q015 get configmap apiserver-fixed-manifest -o yaml
```
