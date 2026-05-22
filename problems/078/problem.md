# Problem 078: 인증서 체인 확인

| 항목 | 값 |
|------|-----|
| 문제 번호 | 078 |
| 도메인 | Cluster Architecture, Installation & Configuration |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 8분 |
| 네임스페이스 | cka-q078 |

## Context

네임스페이스 `cka-q078`에 kube-apiserver 인증서 정보가 담긴 ConfigMap `cert-paths`가 있습니다. 이 정보를 참고하여 인증서 체인을 문서화하세요.

Kubernetes 클러스터의 인증서 체인 구조를 이해하고, 각 인증서의 역할과 관계를 ConfigMap `cert-chain-info`에 기록하세요.

> 참고: https://kubernetes.io/docs/setup/best-practices/certificates/

## Tasks

1. ConfigMap `cert-chain-info`의 `ca-cert` 키에 CA 인증서 정보를 기록하세요:
   - 경로: `/etc/kubernetes/pki/ca.crt`
   - Issuer: `kubernetes`
   - Subject: `kubernetes`
   - 역할: 클러스터 루트 CA

2. ConfigMap `cert-chain-info`의 `apiserver-cert` 키에 API 서버 인증서 정보를 기록하세요:
   - 경로: `/etc/kubernetes/pki/apiserver.crt`
   - Issuer: `kubernetes` (CA에 의해 서명됨)
   - Subject: `kube-apiserver`
   - 역할: API 서버 TLS 서빙 인증서

3. ConfigMap `cert-chain-info`의 `apiserver-kubelet-client` 키에 kubelet 클라이언트 인증서 정보를 기록하세요:
   - 경로: `/etc/kubernetes/pki/apiserver-kubelet-client.crt`
   - Issuer: `kubernetes` (CA에 의해 서명됨)
   - Subject: `kube-apiserver-kubelet-client`
   - 역할: API 서버가 kubelet에 접속할 때 사용하는 클라이언트 인증서

4. 수정된 ConfigMap을 클러스터에 적용하세요.

## Expected Outcome

- `ca-cert`: CA 인증서 정보 (경로, issuer, subject, 역할)
- `apiserver-cert`: API 서버 인증서 정보
- `apiserver-kubelet-client`: kubelet 클라이언트 인증서 정보

<details>
<summary>힌트 1</summary>

Kubernetes PKI 구조:
- CA (ca.crt/ca.key): 모든 인증서의 루트
- API Server (apiserver.crt): API 서버의 TLS 인증서
- kubelet client (apiserver-kubelet-client.crt): API 서버 → kubelet 통신용

</details>

<details>
<summary>힌트 2</summary>

인증서 정보 확인 명령어:
```bash
openssl x509 -in /etc/kubernetes/pki/ca.crt -text -noout | grep -E "Issuer|Subject|Not After"
```

</details>

<details>
<summary>힌트 3</summary>

인증서 체인 관계:
```
CA (ca.crt) - 자체 서명 (Self-signed)
├── apiserver.crt - CA가 서명
├── apiserver-kubelet-client.crt - CA가 서명
├── front-proxy-ca.crt - 별도 CA
└── etcd/ca.crt - etcd 전용 CA
```

</details>
