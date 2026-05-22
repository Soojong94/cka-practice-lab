# Problem 078: 정답 풀이

## Step 1: 인증서 경로 확인

```bash
kubectl -n cka-q078 get configmap cert-paths -o yaml
```

## Step 2: ConfigMap 수정

```bash
kubectl -n cka-q078 apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: cert-chain-info
  namespace: cka-q078
data:
  ca-cert: |
    path: /etc/kubernetes/pki/ca.crt
    issuer: kubernetes
    subject: kubernetes
    role: Cluster Root CA (self-signed)
  apiserver-cert: |
    path: /etc/kubernetes/pki/apiserver.crt
    issuer: kubernetes
    subject: kube-apiserver
    role: API Server TLS serving certificate
  apiserver-kubelet-client: |
    path: /etc/kubernetes/pki/apiserver-kubelet-client.crt
    issuer: kubernetes
    subject: kube-apiserver-kubelet-client
    role: Client certificate for API server to kubelet communication
EOF
```

## 핵심 개념

- **PKI (Public Key Infrastructure)**: Kubernetes는 컴포넌트 간 통신을 위해 자체 PKI를 운영
- **CA 인증서 (ca.crt)**: 클러스터의 루트 인증 기관, 자체 서명됨
- **서버 인증서 (apiserver.crt)**: API 서버가 클라이언트에게 자신을 증명하는 TLS 인증서
- **클라이언트 인증서 (apiserver-kubelet-client.crt)**: API 서버가 kubelet에 접속할 때 사용
- **인증서 체인**: CA → 서버/클라이언트 인증서 순서로 신뢰 관계 형성

## 검증

```bash
kubectl -n cka-q078 get configmap cert-chain-info -o yaml
```
