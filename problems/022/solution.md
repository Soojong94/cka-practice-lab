# Problem 022: 정답 풀이

## Step 1: 노드 상태 확인

```bash
kubectl -n cka-q022 get configmap node-describe-output -o jsonpath='{.data.node-status}'
```

출력에서 `Ready False` 조건과 `certificate has expired` 메시지를 확인합니다.

## Step 2: kubelet 로그 분석

```bash
kubectl -n cka-q022 get configmap node-describe-output -o jsonpath='{.data.kubelet-logs}'
```

핵심 에러 메시지:
- `kubelet certificate has expired`
- `failed to find any PEM data in certificate input`
- `Part of the existing bootstrap client certificate is expired`

## Step 3: 진단 결과

- **근본 원인**: kubelet의 클라이언트 인증서가 만료됨
- **해결 방법**: kubeadm으로 인증서 갱신 후 kubelet 재시작

## Step 4: ConfigMap 생성

```bash
kubectl -n cka-q022 create configmap node-fix-answer \
  --from-literal=root-cause="kubelet certificate expired" \
  --from-literal=fix-command="kubeadm certs renew kubelet-client" \
  --from-literal=restart-command="systemctl restart kubelet"
```

## 검증

```bash
kubectl -n cka-q022 get configmap node-fix-answer -o yaml
```

## 참고: 실제 환경에서의 해결 절차

```bash
# 1. 문제 노드에 SSH 접속
ssh worker-node-1

# 2. 인증서 만료 확인
openssl x509 -in /var/lib/kubelet/pki/kubelet-client-current.pem -noout -dates

# 3. 인증서 갱신
sudo kubeadm certs renew kubelet-client

# 4. kubelet 재시작
sudo systemctl restart kubelet

# 5. 노드 상태 확인
kubectl get nodes
```
