#!/bin/bash
# Problem 073: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q073"
PASS=0
TOTAL=0

check_cluster

# ConfigMap에서 명령어 추출
MEMBER_LIST=$(kubectl -n "$NAMESPACE" get configmap etcd-commands -o jsonpath='{.data.member-list}' 2>/dev/null)
ENDPOINT_HEALTH=$(kubectl -n "$NAMESPACE" get configmap etcd-commands -o jsonpath='{.data.endpoint-health}' 2>/dev/null)
ENDPOINT_STATUS=$(kubectl -n "$NAMESPACE" get configmap etcd-commands -o jsonpath='{.data.endpoint-status}' 2>/dev/null)

# Task 1: member list 명령어 확인
TOTAL=$((TOTAL+1))
if echo "$MEMBER_LIST" | grep -q 'etcdctl.*member.*list'; then
  print_pass "Task 1: member-list에 etcdctl member list 명령어 포함"
  PASS=$((PASS+1))
else
  print_fail "Task 1: member-list에 etcdctl member list 명령어 없음" "etcdctl member list 명령어를 작성하세요"
fi

# Task 2: member list에 인증서 플래그 확인
TOTAL=$((TOTAL+1))
ML_CACERT=$(echo "$MEMBER_LIST" | grep -c '\-\-cacert')
ML_CERT=$(echo "$MEMBER_LIST" | grep -c '\-\-cert')
ML_KEY=$(echo "$MEMBER_LIST" | grep -c '\-\-key')
ML_ENDPOINTS=$(echo "$MEMBER_LIST" | grep -c '\-\-endpoints')
if [ "$ML_CACERT" -ge 1 ] && [ "$ML_CERT" -ge 1 ] && [ "$ML_KEY" -ge 1 ] && [ "$ML_ENDPOINTS" -ge 1 ]; then
  print_pass "Task 2: member-list에 인증서 플래그 모두 포함"
  PASS=$((PASS+1))
else
  print_fail "Task 2: member-list에 인증서 플래그 누락" "--endpoints, --cacert, --cert, --key 모두 포함하세요"
fi

# Task 3: endpoint health 명령어 확인
TOTAL=$((TOTAL+1))
if echo "$ENDPOINT_HEALTH" | grep -q 'etcdctl.*endpoint.*health'; then
  print_pass "Task 3: endpoint-health에 etcdctl endpoint health 명령어 포함"
  PASS=$((PASS+1))
else
  print_fail "Task 3: endpoint-health에 etcdctl endpoint health 명령어 없음" "etcdctl endpoint health 명령어를 작성하세요"
fi

# Task 4: endpoint health에 인증서 플래그 확인
TOTAL=$((TOTAL+1))
EH_CACERT=$(echo "$ENDPOINT_HEALTH" | grep -c '\-\-cacert')
EH_CERT=$(echo "$ENDPOINT_HEALTH" | grep -c '\-\-cert')
EH_KEY=$(echo "$ENDPOINT_HEALTH" | grep -c '\-\-key')
EH_ENDPOINTS=$(echo "$ENDPOINT_HEALTH" | grep -c '\-\-endpoints')
if [ "$EH_CACERT" -ge 1 ] && [ "$EH_CERT" -ge 1 ] && [ "$EH_KEY" -ge 1 ] && [ "$EH_ENDPOINTS" -ge 1 ]; then
  print_pass "Task 4: endpoint-health에 인증서 플래그 모두 포함"
  PASS=$((PASS+1))
else
  print_fail "Task 4: endpoint-health에 인증서 플래그 누락" "--endpoints, --cacert, --cert, --key 모두 포함하세요"
fi

# Task 5: endpoint status 명령어 확인
TOTAL=$((TOTAL+1))
if echo "$ENDPOINT_STATUS" | grep -q 'etcdctl.*endpoint.*status'; then
  HAS_FLAGS=true
  ES_CACERT=$(echo "$ENDPOINT_STATUS" | grep -c '\-\-cacert')
  ES_CERT=$(echo "$ENDPOINT_STATUS" | grep -c '\-\-cert')
  ES_KEY=$(echo "$ENDPOINT_STATUS" | grep -c '\-\-key')
  ES_ENDPOINTS=$(echo "$ENDPOINT_STATUS" | grep -c '\-\-endpoints')
  if [ "$ES_CACERT" -ge 1 ] && [ "$ES_CERT" -ge 1 ] && [ "$ES_KEY" -ge 1 ] && [ "$ES_ENDPOINTS" -ge 1 ]; then
    print_pass "Task 5: endpoint-status에 etcdctl endpoint status + 인증서 플래그 포함"
    PASS=$((PASS+1))
  else
    print_fail "Task 5: endpoint-status에 인증서 플래그 누락" "--endpoints, --cacert, --cert, --key 모두 포함하세요"
  fi
else
  print_fail "Task 5: endpoint-status에 etcdctl endpoint status 명령어 없음" "etcdctl endpoint status 명령어를 작성하세요"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
