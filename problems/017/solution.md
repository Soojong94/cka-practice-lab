# Problem 017: 정답 풀이

## Step 1: 잘못된 매니페스트 확인

```bash
kubectl -n cka-q017 get configmap controller-manager-broken-manifest -o jsonpath='{.data.manifest}'
```

두 개의 플래그에서 잘못된 경로를 확인할 수 있습니다:
- `--cluster-signing-cert-file=/etc/kubernetes/pki/wrong-ca.crt`
- `--cluster-signing-key-file=/etc/kubernetes/pki/wrong-ca.key`

## Step 2: 에러 로그 확인

```bash
kubectl -n cka-q017 get configmap controller-manager-broken-manifest -o jsonpath='{.data.error-log}'
```

`open /etc/kubernetes/pki/wrong-ca.crt: no such file or directory` 에러를 확인합니다.

## Step 3: 수정된 매니페스트로 ConfigMap 생성

```bash
kubectl -n cka-q017 get configmap controller-manager-broken-manifest -o jsonpath='{.data.manifest}' | \
  sed 's/wrong-ca.crt/ca.crt/g; s/wrong-ca.key/ca.key/g' > /tmp/cm-fixed.yaml

kubectl -n cka-q017 create configmap controller-manager-fixed-manifest \
  --from-file=manifest=/tmp/cm-fixed.yaml
```

## 실제 환경에서의 복구 절차

```bash
# 1. static pod 매니페스트 수정
vi /etc/kubernetes/manifests/kube-controller-manager.yaml

# 2. wrong-ca.crt → ca.crt, wrong-ca.key → ca.key 로 수정
# 3. kubelet이 자동으로 static pod를 재시작함
# 4. 확인
kubectl get pods -n kube-system | grep controller-manager
```

## 검증

```bash
kubectl -n cka-q017 get configmap controller-manager-fixed-manifest -o yaml
```
