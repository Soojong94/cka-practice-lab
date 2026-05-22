# Problem 025: 정답 풀이

## Step 1: etcd manifest 분석

```bash
kubectl -n cka-q025 get configmap etcd-manifest -o jsonpath='{.data.etcd-pod\.yaml}'
```

추출한 정보:
- `--trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt`
- `--cert-file=/etc/kubernetes/pki/etcd/server.crt`
- `--key-file=/etc/kubernetes/pki/etcd/server.key`
- `--advertise-client-urls=https://192.168.65.4:2379`

## Step 2: ConfigMap 생성

```bash
kubectl -n cka-q025 create configmap etcd-commands \
  --from-literal=ca-cert="/etc/kubernetes/pki/etcd/ca.crt" \
  --from-literal=server-cert="/etc/kubernetes/pki/etcd/server.crt" \
  --from-literal=server-key="/etc/kubernetes/pki/etcd/server.key" \
  --from-literal=endpoint="https://192.168.65.4:2379" \
  --from-literal=health-command="etcdctl --endpoints=https://192.168.65.4:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key endpoint health"
```

## 참고: 실제 환경에서의 etcd 관리 명령어

```bash
# etcd Pod에서 직접 실행
kubectl -n kube-system exec -it etcd-master -- etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  endpoint health

# 멤버 목록 확인
etcdctl member list

# 스냅샷 저장
etcdctl snapshot save /tmp/etcd-backup.db

# 스냅샷 상태 확인
etcdctl snapshot status /tmp/etcd-backup.db --write-out=table
```

## 검증

```bash
kubectl -n cka-q025 get configmap etcd-commands -o yaml
```
