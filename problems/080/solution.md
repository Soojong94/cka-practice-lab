# Problem 080: 정답 풀이

## Step 1: ConfigMap 수정

```bash
kubectl -n cka-q080 apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: backup-procedure
  namespace: cka-q080
data:
  etcd-backup: |
    ETCDCTL_API=3 etcdctl snapshot save /backup/etcd-snapshot.db \
      --endpoints=https://127.0.0.1:2379 \
      --cacert=/etc/kubernetes/pki/etcd/ca.crt \
      --cert=/etc/kubernetes/pki/etcd/server.crt \
      --key=/etc/kubernetes/pki/etcd/server.key
  cert-backup-paths: |
    /etc/kubernetes/pki/
    /etc/kubernetes/admin.conf
    /etc/kubernetes/controller-manager.conf
    /etc/kubernetes/scheduler.conf
  kubeadm-config: |
    kubectl -n kube-system get configmap kubeadm-config -o yaml > /backup/kubeadm-config.yaml
  restore-steps: |
    Step 1: etcd 복원
    ETCDCTL_API=3 etcdctl snapshot restore /backup/etcd-snapshot.db --data-dir=/var/lib/etcd
    Step 2: 인증서 복원
    cp -r /backup/pki/ /etc/kubernetes/pki/
    Step 3: kubeadm 설정 복원
    kubectl apply -f /backup/kubeadm-config.yaml
    Step 4: kubelet 재시작
    systemctl restart kubelet
EOF
```

## 핵심 개념

- **etcd 백업**: 클러스터의 모든 상태(리소스 정의, 설정)가 etcd에 저장됨
- **인증서 백업**: 컨트롤 플레인 컴포넌트 간 mTLS 통신에 필요
- **kubeadm 설정**: 클러스터 초기화 시 사용된 설정 (API 서버 주소, 네트워크 설정 등)
- **복원 순서**: etcd → 인증서 → 설정 → kubelet 재시작 (의존성 순서)

## 전체 백업 스크립트 예시

```bash
#!/bin/bash
BACKUP_DIR="/backup/$(date +%Y%m%d)"
mkdir -p $BACKUP_DIR

# 1. etcd 스냅샷
ETCDCTL_API=3 etcdctl snapshot save $BACKUP_DIR/etcd-snapshot.db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key

# 2. 인증서 백업
cp -r /etc/kubernetes/pki/ $BACKUP_DIR/pki/
cp /etc/kubernetes/admin.conf $BACKUP_DIR/
cp /etc/kubernetes/controller-manager.conf $BACKUP_DIR/
cp /etc/kubernetes/scheduler.conf $BACKUP_DIR/

# 3. kubeadm 설정 백업
kubectl -n kube-system get configmap kubeadm-config -o yaml > $BACKUP_DIR/kubeadm-config.yaml
```

## 검증

```bash
kubectl -n cka-q080 get configmap backup-procedure -o yaml
```
