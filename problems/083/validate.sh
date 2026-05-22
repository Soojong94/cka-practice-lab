#!/bin/bash
# Problem 083: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q083"
PASS=0
TOTAL=0

check_cluster

# Task 1: dns-test Pod 존재 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get pod dns-test &>/dev/null; then
  POD_STATUS=$(kubectl -n "$NAMESPACE" get pod dns-test -o jsonpath='{.status.phase}')
  if [ "$POD_STATUS" = "Running" ]; then
    print_pass "Task 1: Pod 'dns-test' Running 상태"
    PASS=$((PASS+1))
  else
    print_fail "Task 1: Pod 'dns-test' Running 아님 (현재: $POD_STATUS)" \
      "busybox 이미지로 sleep 3600 명령 실행"
  fi
else
  print_fail "Task 1: Pod 'dns-test' 미생성" \
    "kubectl run dns-test --image=busybox:1.36 --command -- sleep 3600"
fi

# Task 2: ConfigMap 'dns-result' 존재 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get configmap dns-result &>/dev/null; then
  print_pass "Task 2: ConfigMap 'dns-result' 존재"
  PASS=$((PASS+1))
else
  print_fail "Task 2: ConfigMap 'dns-result' 미생성" \
    "DNS 해석 결과를 ConfigMap에 저장하세요"
fi

# Task 3: ConfigMap에 올바른 FQDN 저장 확인
TOTAL=$((TOTAL+1))
NORMAL_FQDN=$(kubectl -n "$NAMESPACE" get configmap dns-result -o jsonpath='{.data.normal-fqdn}' 2>/dev/null)
HEADLESS_FQDN=$(kubectl -n "$NAMESPACE" get configmap dns-result -o jsonpath='{.data.headless-fqdn}' 2>/dev/null)
if [ "$NORMAL_FQDN" = "normal-svc.cka-q083.svc.cluster.local" ] && \
   [ "$HEADLESS_FQDN" = "headless-svc.cka-q083.svc.cluster.local" ]; then
  print_pass "Task 3: FQDN 올바르게 저장됨"
  PASS=$((PASS+1))
else
  print_fail "Task 3: FQDN 불일치 (normal=$NORMAL_FQDN, headless=$HEADLESS_FQDN)" \
    "형식: <service>.<namespace>.svc.cluster.local"
fi

# Task 4: 해석 결과 타입 확인
TOTAL=$((TOTAL+1))
NORMAL_TYPE=$(kubectl -n "$NAMESPACE" get configmap dns-result -o jsonpath='{.data.normal-resolves-to}' 2>/dev/null)
HEADLESS_TYPE=$(kubectl -n "$NAMESPACE" get configmap dns-result -o jsonpath='{.data.headless-resolves-to}' 2>/dev/null)
if [ "$NORMAL_TYPE" = "clusterip" ] && [ "$HEADLESS_TYPE" = "pod-ips" ]; then
  print_pass "Task 4: DNS 해석 결과 타입 올바름 (normal=clusterip, headless=pod-ips)"
  PASS=$((PASS+1))
else
  print_fail "Task 4: DNS 해석 결과 타입 불일치 (normal=$NORMAL_TYPE, headless=$HEADLESS_TYPE)" \
    "normal-resolves-to: clusterip, headless-resolves-to: pod-ips"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
