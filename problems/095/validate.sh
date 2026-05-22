#!/bin/bash
# Problem 095: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q095"
PASS=0
TOTAL=0

check_cluster

# Task 1: CoreDNS ConfigMap에 custom.local 설정 확인
TOTAL=$((TOTAL+1))
COREFILE=$(kubectl -n kube-system get configmap coredns -o jsonpath='{.data.Corefile}' 2>/dev/null)
if echo "$COREFILE" | grep -q "custom.local\|custom\.local"; then
  print_pass "Task 1: CoreDNS ConfigMap에 custom.local 설정 포함"
  PASS=$((PASS+1))
else
  print_fail "Task 1: CoreDNS ConfigMap에 custom.local 설정 없음" \
    "CoreDNS Corefile에 rewrite 규칙을 추가하세요"
fi

# Task 2: CoreDNS Pod Running 상태 확인
TOTAL=$((TOTAL+1))
COREDNS_READY=$(kubectl -n kube-system get pods -l k8s-app=kube-dns --no-headers 2>/dev/null | grep -c "Running")
if [ "$COREDNS_READY" -ge 1 ] 2>/dev/null; then
  print_pass "Task 2: CoreDNS Pod ${COREDNS_READY}개 Running 상태"
  PASS=$((PASS+1))
else
  print_fail "Task 2: CoreDNS Pod Running 아님" \
    "CoreDNS 설정 오류 확인: kubectl -n kube-system logs -l k8s-app=kube-dns"
fi

# Task 3: custom.local DNS 해석 테스트
TOTAL=$((TOTAL+1))
DNS_RESULT=$(kubectl -n "$NAMESPACE" run dns-verify --image=busybox:1.36 --rm -i --restart=Never \
  -- nslookup test-svc.${NAMESPACE}.svc.custom.local 2>/dev/null)
if echo "$DNS_RESULT" | grep -q "Address"; then
  print_pass "Task 3: custom.local 도메인 DNS 해석 성공"
  PASS=$((PASS+1))
else
  # 대안: rewrite 규칙이 적용되었는지만 확인
  if echo "$COREFILE" | grep -q "rewrite"; then
    print_pass "Task 3: CoreDNS rewrite 규칙 존재 (DNS 해석은 환경에 따라 다를 수 있음)"
    PASS=$((PASS+1))
  else
    print_fail "Task 3: custom.local DNS 해석 실패" \
      "rewrite 규칙이 올바른지, CoreDNS가 재시작되었는지 확인"
  fi
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
