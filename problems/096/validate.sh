#!/bin/bash
# Problem 096: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NS_A="cka-q096-a"
NS_B="cka-q096-b"
PASS=0
TOTAL=0

check_cluster

# Task 1: ConfigMap 'cross-ns-result' 존재 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NS_A" get configmap cross-ns-result &>/dev/null; then
  print_pass "Task 1: ConfigMap 'cross-ns-result' 존재"
  PASS=$((PASS+1))
else
  print_fail "Task 1: ConfigMap 'cross-ns-result' 미생성" \
    "cka-q096-a 네임스페이스에 ConfigMap을 생성하세요"
fi

# Task 2: FQDN 확인
TOTAL=$((TOTAL+1))
FQDN=$(kubectl -n "$NS_A" get configmap cross-ns-result -o jsonpath='{.data.fqdn}' 2>/dev/null)
if [ "$FQDN" = "svc-b.cka-q096-b.svc.cluster.local" ]; then
  print_pass "Task 2: FQDN=svc-b.cka-q096-b.svc.cluster.local 올바름"
  PASS=$((PASS+1))
else
  print_fail "Task 2: FQDN 불일치 (현재: $FQDN)" \
    "형식: <service>.<namespace>.svc.cluster.local"
fi

# Task 3: curl 명령어 확인
TOTAL=$((TOTAL+1))
CURL_CMD=$(kubectl -n "$NS_A" get configmap cross-ns-result -o jsonpath='{.data.curl-command}' 2>/dev/null)
if echo "$CURL_CMD" | grep -q "curl.*svc-b.cka-q096-b"; then
  print_pass "Task 3: curl 명령어 올바름"
  PASS=$((PASS+1))
else
  print_fail "Task 3: curl 명령어 불일치 (현재: $CURL_CMD)" \
    "curl -s http://svc-b.cka-q096-b.svc.cluster.local 형식"
fi

# Task 4: 결과에 nginx 응답 포함 확인
TOTAL=$((TOTAL+1))
RESULT=$(kubectl -n "$NS_A" get configmap cross-ns-result -o jsonpath='{.data.result}' 2>/dev/null)
if echo "$RESULT" | grep -qi "nginx\|welcome\|html"; then
  print_pass "Task 4: curl 결과에 nginx 응답 포함"
  PASS=$((PASS+1))
else
  print_fail "Task 4: curl 결과에 nginx 응답 없음" \
    "pod-a에서 svc-b로 curl 실행 후 결과를 저장하세요"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
