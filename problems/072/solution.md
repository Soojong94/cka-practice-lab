# Problem 072: 정답 풀이

## Step 1: etcd 정보 확인

```bash
kubectl -n cka-q072 get configmap etcd-info -o yaml
```

## Step 2: backup.sh 작성

```bash
kubectl -n cka-q072 apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: etcd-scripts
  namespace: cka-q072
data:
  backup.sh: |
    #!/bin/bash
    ETCDCTL_API=3 etcdctl snapshot save /tmp/etcd-backup.db \
      --endpoints=https://127.0.0.1:2379 \
      --cacert=/etc/kubernetes/pki/etcd/ca.crt \
      --cert=/etc/kubernetes/pki/etcd/server.crt \
      --key=/etc/kubernetes/pki/etcd/server.key
  restore.sh: |
    #!/bin/bash
    ETCDCTL_API=3 etcdctl snapshot restore /tmp/etcd-backup.db \
      --data-dir=/var/lib/etcd-restored
EOF
```

## 핵심 개념

- **etcdctl snapshot save**: etcd 데이터의 스냅샷을 파일로 저장
- **etcdctl snapshot restore**: 스냅샷에서 새로운 etcd 데이터 디렉토리로 복원
- **인증서 플래그**: etcd는 TLS로 보호되므로 CA 인증서, 클라이언트 인증서, 키가 필요
- **ETCDCTL_API=3**: etcd v3 API 사용을 명시

## 검증

```bash
kubectl -n cka-q072 get configmap etcd-scripts -o jsonpath='{.data.backup\.sh}'
kubectl -n cka-q072 get configmap etcd-scripts -o jsonpath='{.data.restore\.sh}'
```
