#!/bin/bash
# Problem 070: kubeconfig 인증서 디코딩
# Domain: Cluster Architecture, Installation & Configuration
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q070"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. 테스트용 인증서 생성
mkdir -p /tmp/cka-q070

# CA 인증서 생성
openssl req -x509 -newkey rsa:2048 \
  -keyout /tmp/cka-q070/ca.key -out /tmp/cka-q070/ca.crt \
  -days 365 -nodes -subj "/CN=kubernetes-ca/O=kubernetes" 2>/dev/null

# 클라이언트 인증서 생성 (CA로 서명, 만료일 90일)
openssl req -newkey rsa:2048 \
  -keyout /tmp/cka-q070/client.key -out /tmp/cka-q070/client.csr \
  -nodes -subj "/CN=admin-user/O=system:masters" 2>/dev/null

openssl x509 -req -in /tmp/cka-q070/client.csr \
  -CA /tmp/cka-q070/ca.crt -CAkey /tmp/cka-q070/ca.key \
  -CAcreateserial -out /tmp/cka-q070/client.crt \
  -days 90 2>/dev/null

# base64 인코딩
CLIENT_CERT_B64=$(base64 -w 0 /tmp/cka-q070/client.crt 2>/dev/null || base64 /tmp/cka-q070/client.crt | tr -d '\n')
CLIENT_KEY_B64=$(base64 -w 0 /tmp/cka-q070/client.key 2>/dev/null || base64 /tmp/cka-q070/client.key | tr -d '\n')
CA_CERT_B64=$(base64 -w 0 /tmp/cka-q070/ca.crt 2>/dev/null || base64 /tmp/cka-q070/ca.crt | tr -d '\n')

# kubeconfig 파일 생성
cat > /tmp/cka-q070/kubeconfig <<EOF
apiVersion: v1
kind: Config
current-context: admin-context
clusters:
- cluster:
    certificate-authority-data: ${CA_CERT_B64}
    server: https://10.0.0.1:6443
  name: production-cluster
contexts:
- context:
    cluster: production-cluster
    namespace: default
    user: admin-user
  name: admin-context
users:
- name: admin-user
  user:
    client-certificate-data: ${CLIENT_CERT_B64}
    client-key-data: ${CLIENT_KEY_B64}
EOF

# 인증서 정보를 ConfigMap에 저장 (검증용)
ISSUER=$(openssl x509 -in /tmp/cka-q070/client.crt -noout -issuer 2>/dev/null | sed 's/issuer=//' | sed 's/issuer= //')
EXPIRY=$(openssl x509 -in /tmp/cka-q070/client.crt -noout -enddate 2>/dev/null | sed 's/notAfter=//')

kubectl -n "$NAMESPACE" create configmap cert-answer \
  --from-literal=expected-issuer="$ISSUER" \
  --from-literal=expected-expiry="$EXPIRY" 2>/dev/null || true

# 4. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/070"
echo -e "${YELLOW}[INFO] kubeconfig 파일: /tmp/cka-q070/kubeconfig${NC}"
