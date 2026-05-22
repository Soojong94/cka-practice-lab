# Problem 076: 정답 풀이

## Step 1: CNI 플러그인 확인

```bash
# kube-system에서 네트워크 관련 DaemonSet 확인
kubectl -n kube-system get daemonsets
kubectl -n kube-system get pods | grep -i 'cni\|calico\|flannel\|weave\|kindnet\|vpnkit'
```

## Step 2: Pod CIDR 확인

```bash
kubectl get nodes -o jsonpath='{.items[*].spec.podCIDR}'
# 또는
kubectl cluster-info dump | grep -m 1 cluster-cidr
```

## Step 3: ConfigMap 수정

```bash
# Docker Desktop 환경 기준 (실제 값은 환경에 따라 다를 수 있음)
POD_CIDR=$(kubectl get nodes -o jsonpath='{.items[0].spec.podCIDR}')
CNI_PLUGIN=$(kubectl -n kube-system get daemonsets -o name | head -1 | sed 's|daemonset.apps/||')

kubectl -n cka-q076 apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: cni-info
  namespace: cka-q076
data:
  cni-plugin: "$CNI_PLUGIN"
  config-path: "/etc/cni/net.d/"
  pod-cidr: "$POD_CIDR"
EOF
```

## 핵심 개념

- **CNI (Container Network Interface)**: 컨테이너 네트워크 설정을 위한 표준 인터페이스
- **CNI 설정 디렉토리**: `/etc/cni/net.d/` (kubelet이 이 디렉토리에서 CNI 설정을 읽음)
- **Pod CIDR**: Pod에 할당되는 IP 주소 범위
- **일반적인 CNI 플러그인**: Calico, Flannel, Weave, Cilium, kindnet

## 검증

```bash
kubectl -n cka-q076 get configmap cni-info -o yaml
```
