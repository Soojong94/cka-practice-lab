# Problem 024: 정답 풀이

## Step 1: apiserver 인증서 만료일 확인

```bash
kubectl -n cka-q024 get configmap cert-info -o jsonpath='{.data.apiserver-cert}'
```

출력에서 `Not After : Jan 15 00:00:00 2025 GMT` 확인

## Step 2: 전체 인증서 상태 확인

```bash
kubectl -n cka-q024 get configmap cert-info -o jsonpath='{.data.kubeadm-certs-output}'
```

모든 인증서가 30일 후 만료 예정임을 확인

## Step 3: ConfigMap 생성

```bash
kubectl -n cka-q024 create configmap cert-renewal-answer \
  --from-literal=expiry-date="Jan 15 00:00:00 2025 GMT" \
  --from-literal=renew-command="kubeadm certs renew all" \
  --from-literal=check-command="kubeadm certs check-expiration"
```

## 참고: 실제 환경에서의 인증서 관리

```bash
# 1. 인증서 만료일 확인
kubeadm certs check-expiration

# 2. 모든 인증서 갱신
kubeadm certs renew all

# 3. 갱신 후 컨트롤 플레인 컴포넌트 재시작
# (static pod이므로 자동 재시작됨, 또는 수동으로)
crictl pods --name kube-apiserver -q | xargs crictl stopp
crictl pods --name kube-controller-manager -q | xargs crictl stopp
crictl pods --name kube-scheduler -q | xargs crictl stopp

# 4. 갱신 확인
kubeadm certs check-expiration
```

## 검증

```bash
kubectl -n cka-q024 get configmap cert-renewal-answer -o yaml
```
