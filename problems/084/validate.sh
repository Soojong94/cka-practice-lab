#!/bin/bash
# Problem 084: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q084"
PASS=0
TOTAL=0

check_cluster

# Task 1: Headless Service 'db-headless' 존재 및 clusterIP=None 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get svc db-headless &>/dev/null; then
  CLUSTER_IP=$(kubectl -n "$NAMESPACE" get svc db-headless -o jsonpath='{.spec.clusterIP}')
  if [ "$CLUSTER_IP" = "None" ]; then
    print_pass "Task 1: Service 'db-headless' Headless (clusterIP=None) 확인"
    PASS=$((PASS+1))
  else
    print_fail "Task 1: Service 'db-headless' clusterIP가 None이 아님 (현재: $CLUSTER_IP)" \
      "spec.clusterIP: None 설정 확인"
  fi
else
  print_fail "Task 1: Service 'db-headless' 미생성" "Headless Service를 생성하세요"
fi

# Task 2: Service selector 확인
TOTAL=$((TOTAL+1))
SVC_SELECTOR=$(kubectl -n "$NAMESPACE" get svc db-headless -o jsonpath='{.spec.selector.app}' 2>/dev/null)
SVC_PORT=$(kubectl -n "$NAMESPACE" get svc db-headless -o jsonpath='{.spec.ports[0].port}' 2>/dev/null)
if [ "$SVC_SELECTOR" = "db" ] && [ "$SVC_PORT" = "5432" ]; then
  print_pass "Task 2: Service selector=app:db, port=5432 올바름"
  PASS=$((PASS+1))
else
  print_fail "Task 2: Service 스펙 불일치 (selector=$SVC_SELECTOR, port=$SVC_PORT)" \
    "selector: app: db, port: 5432 확인"
fi

# Task 3: StatefulSet Pod 개별 DNS 해석 확인
TOTAL=$((TOTAL+1))
DNS_OK=true
for i in 0 1 2; do
  # Pod가 Running인지 확인
  POD_STATUS=$(kubectl -n "$NAMESPACE" get pod "db-$i" -o jsonpath='{.status.phase}' 2>/dev/null)
  if [ "$POD_STATUS" != "Running" ]; then
    DNS_OK=false
    break
  fi
done

if [ "$DNS_OK" = true ]; then
  # DNS 해석 테스트
  DNS_RESULT=$(kubectl -n "$NAMESPACE" run dns-verify --image=busybox:1.36 --rm -i --restart=Never \
    -- nslookup db-0.db-headless.${NAMESPACE}.svc.cluster.local 2>/dev/null)
  if echo "$DNS_RESULT" | grep -q "Address"; then
    print_pass "Task 3: StatefulSet Pod 개별 DNS 해석 성공 (db-0.db-headless)"
    PASS=$((PASS+1))
  else
    print_fail "Task 3: StatefulSet Pod DNS 해석 실패" \
      "Headless Service 이름이 StatefulSet의 serviceName과 일치하는지 확인"
  fi
else
  print_fail "Task 3: StatefulSet Pod가 모두 Running 상태가 아님" \
    "Pod 상태를 확인하세요"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
