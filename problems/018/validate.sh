#!/bin/bash
# Problem 018: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q018"
PASS=0
TOTAL=0

check_cluster

# Task 1: CoreDNS Pod가 Running 상태인지 확인
TOTAL=$((TOTAL+1))
COREDNS_RUNNING=$(kubectl -n kube-system get pods -l k8s-app=kube-dns --field-selector=status.phase=Running --no-headers 2>/dev/null | wc -l)
if [ "$COREDNS_RUNNING" -ge 1 ]; then
  print_pass "Task 1: CoreDNS Pod Running 상태 (${COREDNS_RUNNING}개)"
  PASS=$((PASS+1))
else
  print_fail "Task 1: CoreDNS Pod Running 아님" \
    "CoreDNS ConfigMap의 Corefile 문법을 수정하세요"
fi

# Task 2: CoreDNS ConfigMap에 올바른 kubernetes 블록 확인
TOTAL=$((TOTAL+1))
COREFILE=$(kubectl -n kube-system get configmap coredns -o jsonpath='{.data.Corefile}' 2>/dev/null)
# kubernetes 블록이 닫는 중괄호를 포함하는지 확인
if echo "$COREFILE" | grep -A1 "ttl 30" | grep -q "}"; then
  print_pass "Task 2: CoreDNS Corefile kubernetes 블록 문법 올바름"
  PASS=$((PASS+1))
else
  print_fail "Task 2: CoreDNS Corefile kubernetes 블록에 닫는 중괄호 누락" \
    "kubernetes 블록의 닫는 }를 추가하세요"
fi

# Task 3: DNS 해석 테스트
TOTAL=$((TOTAL+1))
# 테스트용 Pod로 DNS 확인
DNS_RESULT=$(kubectl -n "$NAMESPACE" run dns-test --image=busybox:1.36 --restart=Never --rm -i --timeout=30s -- nslookup kubernetes.default.svc.cluster.local 2>/dev/null)
if echo "$DNS_RESULT" | grep -q "Address"; then
  print_pass "Task 3: DNS 해석 정상 동작 (kubernetes.default.svc.cluster.local)"
  PASS=$((PASS+1))
else
  print_fail "Task 3: DNS 해석 실패" \
    "CoreDNS가 정상 동작하는지 확인하세요"
fi

# Task 4: CoreDNS Deployment Ready 확인
TOTAL=$((TOTAL+1))
READY=$(kubectl -n kube-system get deployment coredns -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
DESIRED=$(kubectl -n kube-system get deployment coredns -o jsonpath='{.spec.replicas}' 2>/dev/null)
if [ "$READY" = "$DESIRED" ] && [ -n "$READY" ]; then
  print_pass "Task 4: CoreDNS Deployment Ready ($READY/$DESIRED)"
  PASS=$((PASS+1))
else
  print_fail "Task 4: CoreDNS Deployment Ready 아님 (${READY:-0}/${DESIRED:-2})" \
    "CoreDNS Pod를 재시작하세요: kubectl -n kube-system rollout restart deployment coredns"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
