# Problem 061: 정답 풀이

## Step 1: 클러스터 정보 확인

```bash
kubectl -n cka-q061 get configmap cluster-info -o yaml

# 업그레이드 대상 노드 이름 (Docker Desktop 기본: docker-desktop)
NODE=$(kubectl -n cka-q061 get configmap cluster-info -o jsonpath='{.data.node-name}')
```

## Step 2: ConfigMap 생성

```bash
kubectl -n cka-q061 create configmap upgrade-procedure \
  --from-literal=step1="kubectl drain $NODE --ignore-daemonsets --delete-emptydir-data" \
  --from-literal=step2="kubeadm upgrade plan && kubeadm upgrade apply v1.29.0" \
  --from-literal=step3="systemctl daemon-reload && systemctl restart kubelet && kubectl uncordon $NODE" \
  --from-literal=upgrade-order="drain,upgrade-kubeadm,upgrade-apply,upgrade-kubelet,restart-kubelet,uncordon"
```

## 업그레이드 절차 설명

### 1단계: 노드 Drain
```bash
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data
```
- 노드에서 실행 중인 Pod를 안전하게 퇴거
- DaemonSet Pod는 무시 (--ignore-daemonsets)
- emptyDir 데이터 삭제 허용 (--delete-emptydir-data)

### 2단계: kubeadm 업그레이드
```bash
# 업그레이드 가능 여부 확인
kubeadm upgrade plan

# 실제 업그레이드 적용
kubeadm upgrade apply v1.29.0
```

### 3단계: kubelet/kubectl 업그레이드 및 노드 복구
```bash
# 패키지 업그레이드 (Ubuntu/Debian 기준)
apt-get update && apt-get install -y kubelet=1.29.0-00 kubectl=1.29.0-00

# kubelet 재시작
systemctl daemon-reload
systemctl restart kubelet

# 노드 스케줄 가능 상태로 복구
kubectl uncordon <node-name>
```

## 검증

```bash
kubectl -n cka-q061 get configmap upgrade-procedure -o yaml
```
