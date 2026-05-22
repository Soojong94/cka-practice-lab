# Problem 014: 정답 풀이

## Step 1: 시나리오 로그 확인

```bash
kubectl -n cka-q014 get configmap kubelet-scenario -o yaml
```

로그에서 다음을 확인할 수 있습니다:
- `failed to run Kubelet: invalid kubelet configuration` - kubelet 설정 파일 오류
- kubelet이 반복적으로 재시작되고 있음

## Step 2: 노드 정보 확인

ConfigMap의 `node-info` 키에서:
- kubelet config path: `/var/lib/kubelet/config.yaml`
- kubelet service file: `/etc/systemd/system/kubelet.service.d/10-kubeadm.conf`

## Step 3: 답안 ConfigMap 생성

```bash
kubectl -n cka-q014 create configmap kubelet-answer \
  --from-literal=cause="invalid kubelet configuration" \
  --from-literal=restart-command="systemctl restart kubelet" \
  --from-literal=enable-command="systemctl enable kubelet" \
  --from-literal=check-command="systemctl status kubelet" \
  --from-literal=config-path="/var/lib/kubelet/config.yaml"
```

## 실제 환경에서의 복구 절차

```bash
# 1. kubelet 상태 확인
systemctl status kubelet

# 2. kubelet 로그 확인
journalctl -u kubelet -n 50

# 3. kubelet 설정 파일 확인 및 수정
vi /var/lib/kubelet/config.yaml

# 4. kubelet 재시작
systemctl restart kubelet

# 5. kubelet 자동 시작 설정
systemctl enable kubelet

# 6. 상태 재확인
systemctl status kubelet
```

## 검증

```bash
kubectl -n cka-q014 get configmap kubelet-answer -o yaml
```
