# Problem 073: 정답 풀이

## Step 1: etcd 클러스터 정보 확인

```bash
kubectl -n cka-q073 get configmap etcd-cluster-info -o yaml
```

## Step 2: etcd-commands ConfigMap 수정

```bash
kubectl -n cka-q073 apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: etcd-commands
  namespace: cka-q073
data:
  member-list: |
    ETCDCTL_API=3 etcdctl member list \
      --endpoints=https://127.0.0.1:2379 \
      --cacert=/etc/kubernetes/pki/etcd/ca.crt \
      --cert=/etc/kubernetes/pki/etcd/server.crt \
      --key=/etc/kubernetes/pki/etcd/server.key
  endpoint-health: |
    ETCDCTL_API=3 etcdctl endpoint health \
      --endpoints=https://127.0.0.1:2379 \
      --cacert=/etc/kubernetes/pki/etcd/ca.crt \
      --cert=/etc/kubernetes/pki/etcd/server.crt \
      --key=/etc/kubernetes/pki/etcd/server.key
  endpoint-status: |
    ETCDCTL_API=3 etcdctl endpoint status \
      --endpoints=https://127.0.0.1:2379 \
      --cacert=/etc/kubernetes/pki/etcd/ca.crt \
      --cert=/etc/kubernetes/pki/etcd/server.crt \
      --key=/etc/kubernetes/pki/etcd/server.key
EOF
```

## 핵심 개념

- **etcdctl member list**: 클러스터의 모든 멤버(노드) 목록 조회
- **etcdctl endpoint health**: 엔드포인트의 응답 가능 여부 확인
- **etcdctl endpoint status**: 리더 여부, DB 크기, Raft 인덱스 등 상세 정보
- 모든 명령어에 TLS 인증서 플래그가 필요 (etcd는 기본적으로 mTLS 사용)

## 검증

```bash
kubectl -n cka-q073 get configmap etcd-commands -o yaml
```
