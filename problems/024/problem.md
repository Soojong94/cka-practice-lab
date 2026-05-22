# Problem 024: 인증서 만료 확인 및 갱신 (simulated)

| 항목 | 값 |
|------|-----|
| 문제 번호 | 024 |
| 도메인 | Troubleshooting |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 7분 |
| 네임스페이스 | cka-q024 |

## Context

클러스터의 인증서 만료일이 다가오고 있습니다. ConfigMap `cert-info`에 현재 인증서 정보가 저장되어 있습니다. 인증서 만료일을 확인하고 갱신 절차를 문서화해야 합니다.

> 참고: 이 문제는 시뮬레이션입니다. 실제 인증서를 갱신하지 않고 ConfigMap에 답을 작성합니다.

## Tasks

1. ConfigMap `cert-info`의 `apiserver-cert` 데이터에서 kube-apiserver 인증서의 만료일(Not After)을 확인하세요.

2. ConfigMap `cert-info`의 `kubeadm-certs-output` 데이터에서 모든 인증서의 잔여 시간을 확인하세요.

3. 다음 스펙으로 ConfigMap을 생성하세요:
   - 이름: `cert-renewal-answer`
   - 네임스페이스: `cka-q024`
   - 데이터:
     - `expiry-date`: apiserver 인증서 만료일 (예: "Jan 15 00:00:00 2025 GMT")
     - `renew-command`: 모든 인증서를 갱신하는 명령어
     - `check-command`: 인증서 만료일을 확인하는 명령어

4. `renew-command`에는 다음 명령어를 작성하세요:
   - `kubeadm certs renew all`

5. `check-command`에는 다음 명령어를 작성하세요:
   - `kubeadm certs check-expiration`

## Expected Outcome

- ConfigMap `cert-renewal-answer`가 네임스페이스 `cka-q024`에 존재
- `expiry-date` 값에 "Jan 15"과 "2025" 포함
- `renew-command` 값에 `kubeadm certs renew` 포함
- `check-command` 값에 `kubeadm certs check-expiration` 포함

<details>
<summary>힌트 1</summary>

```bash
kubectl -n cka-q024 get configmap cert-info -o jsonpath='{.data.apiserver-cert}'
```

"Not After" 라인에서 만료일을 확인하세요.

</details>

<details>
<summary>힌트 2</summary>

kubeadm 인증서 관련 명령어:
- 확인: `kubeadm certs check-expiration`
- 전체 갱신: `kubeadm certs renew all`
- 개별 갱신: `kubeadm certs renew apiserver`

</details>

<details>
<summary>힌트 3</summary>

```bash
kubectl -n cka-q024 create configmap cert-renewal-answer \
  --from-literal=expiry-date="Jan 15 00:00:00 2025 GMT" \
  --from-literal=renew-command="kubeadm certs renew all" \
  --from-literal=check-command="kubeadm certs check-expiration"
```

</details>
