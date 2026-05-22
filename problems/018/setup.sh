#!/bin/bash
# Problem 018: CoreDNS 설정 오류 수정
# Domain: Troubleshooting
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q018"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. 기존 CoreDNS ConfigMap 백업
echo -e "${YELLOW}[INFO] CoreDNS ConfigMap 백업 중...${NC}"
kubectl -n kube-system get configmap coredns -o yaml > /tmp/coredns-backup.yaml 2>/dev/null

# 4. CoreDNS ConfigMap을 잘못된 설정으로 변경 (닫는 중괄호 누락)
kubectl -n kube-system apply -f - <<'EOF' || fail_with_cleanup "$NAMESPACE" "CoreDNS ConfigMap 수정 실패"
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
data:
  Corefile: |
    .:53 {
        errors
        health {
           lameduck 5s
        }
        ready
        kubernetes cluster.local in-addr.arpa ip6.arpa {
           pods insecure
           fallthrough in-addr.arpa ip6.arpa
           ttl 30

        prometheus :9153
        forward . /etc/resolv.conf {
           max_concurrent 1000
        }
        cache 30
        loop
        reload
        loadbalance
    }
EOF

# 5. CoreDNS Pod 재시작하여 오류 발생시킴
kubectl -n kube-system rollout restart deployment coredns 2>/dev/null
echo -e "${YELLOW}[INFO] CoreDNS 재시작 중... (설정 오류로 인해 비정상 상태 예상)${NC}"
sleep 10

# 6. 백업 정보를 네임스페이스에 저장
kubectl apply -n "$NAMESPACE" -f - <<EOF || true
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns-backup-info
data:
  note: "CoreDNS 원본 설정이 /tmp/coredns-backup.yaml에 백업되어 있습니다."
  hint: "kubernetes 블록의 닫는 중괄호(})가 누락되어 있습니다."
EOF

# 7. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/018"
