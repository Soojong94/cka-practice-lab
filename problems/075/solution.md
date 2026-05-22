# Problem 075: 정답 풀이

## Step 1: 컨테이너 런타임 버전 확인

```bash
kubectl get nodes -o wide
# CONTAINER-RUNTIME 열에서 containerd://1.7.x 형식의 값 확인
```

## Step 2: ConfigMap 수정

```bash
# 런타임 버전 가져오기
RUNTIME_VERSION=$(kubectl get nodes -o jsonpath='{.items[0].status.nodeInfo.containerRuntimeVersion}')

kubectl -n cka-q075 apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: cri-info
  namespace: cka-q075
data:
  runtime-version: "$RUNTIME_VERSION"
  runtime-endpoint: "unix:///run/containerd/containerd.sock"
  list-containers-command: "crictl ps"
  inspect-command: "crictl inspect <CONTAINER_ID>"
EOF
```

## 핵심 개념

- **CRI (Container Runtime Interface)**: kubelet과 컨테이너 런타임 간의 표준 인터페이스
- **containerd**: Docker에서 분리된 산업 표준 컨테이너 런타임
- **crictl**: CRI 호환 런타임을 디버깅하기 위한 CLI 도구
- **소켓 경로**: kubelet이 런타임과 통신하는 Unix 소켓 (containerd: `/run/containerd/containerd.sock`)

## 검증

```bash
kubectl -n cka-q075 get configmap cri-info -o yaml
```
