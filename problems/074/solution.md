# Problem 074: 정답 풀이

## Step 1: 현재 kubelet 설정 확인

```bash
kubectl -n cka-q074 get configmap kubelet-config -o jsonpath='{.data.config\.yaml}'
```

## Step 2: 수정된 ConfigMap 적용

```bash
kubectl -n cka-q074 apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: kubelet-config
  namespace: cka-q074
data:
  config.yaml: |
    apiVersion: kubelet.config.k8s.io/v1beta1
    kind: KubeletConfiguration
    clusterDomain: cluster.local
    clusterDNS:
    - 10.96.0.10
    staticPodPath: /etc/kubernetes/manifests
    authentication:
      anonymous:
        enabled: false
      webhook:
        enabled: true
    authorization:
      mode: Webhook
    cgroupDriver: systemd
    containerRuntimeEndpoint: unix:///var/run/containerd/containerd.sock
    rotateCertificates: true
    serverTLSBootstrap: true
EOF
```

## 핵심 개념

- **clusterDNS**: kubelet이 Pod에 주입하는 DNS 서버 IP (CoreDNS Service ClusterIP: 10.96.0.10)
- **staticPodPath**: kubelet이 Static Pod 매니페스트를 감시하는 디렉토리 (기본: /etc/kubernetes/manifests)
- **authentication.anonymous.enabled**: false로 설정하여 익명 접근 차단
- **authentication.webhook.enabled**: true로 설정하여 API 서버를 통한 인증 활성화
- **authorization.mode: Webhook**: API 서버에 인가 결정을 위임

## 검증

```bash
kubectl -n cka-q074 get configmap kubelet-config -o jsonpath='{.data.config\.yaml}'
```
