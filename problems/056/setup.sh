#!/bin/bash
# Problem 056: kubeconfig context 조작
# Domain: Cluster Architecture, Installation & Configuration
# 이 스크립트는 문제 풀이를 위한 사전 환경을 구성합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q056"

# 1. 클러스터 연결 확인
check_cluster

# 2. 네임스페이스 초기화
init_namespace "$NAMESPACE"

# 3. 커스텀 kubeconfig 파일 생성
mkdir -p /tmp/cka-q056

# 자체 서명 인증서 생성 (테스트용)
openssl req -x509 -newkey rsa:2048 -keyout /tmp/cka-q056/user.key -out /tmp/cka-q056/user.crt \
  -days 365 -nodes -subj "/CN=dev-user/O=dev-team" 2>/dev/null

USER_CERT_B64=$(base64 -w 0 /tmp/cka-q056/user.crt 2>/dev/null || base64 /tmp/cka-q056/user.crt | tr -d '\n')
USER_KEY_B64=$(base64 -w 0 /tmp/cka-q056/user.key 2>/dev/null || base64 /tmp/cka-q056/user.key | tr -d '\n')

# 현재 클러스터 서버 주소 가져오기
CLUSTER_SERVER=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')

cat > /tmp/cka-q056/kubeconfig <<EOF
apiVersion: v1
kind: Config
current-context: dev-context
clusters:
- cluster:
    server: ${CLUSTER_SERVER}
    insecure-skip-tls-verify: true
  name: dev-cluster
- cluster:
    server: https://10.0.0.100:6443
    insecure-skip-tls-verify: true
  name: staging-cluster
- cluster:
    server: https://10.0.0.200:6443
    insecure-skip-tls-verify: true
  name: prod-cluster
contexts:
- context:
    cluster: dev-cluster
    namespace: default
    user: dev-user
  name: dev-context
- context:
    cluster: staging-cluster
    namespace: staging
    user: staging-user
  name: staging-context
- context:
    cluster: prod-cluster
    namespace: production
    user: prod-user
  name: prod-context
users:
- name: dev-user
  user:
    client-certificate-data: ${USER_CERT_B64}
    client-key-data: ${USER_KEY_B64}
- name: staging-user
  user:
    token: staging-token-abc123
- name: prod-user
  user:
    token: prod-token-xyz789
EOF

# 4. 완료 메시지
print_setup_complete "$NAMESPACE" "problems/056"
echo -e "${YELLOW}[INFO] 커스텀 kubeconfig 파일: /tmp/cka-q056/kubeconfig${NC}"
