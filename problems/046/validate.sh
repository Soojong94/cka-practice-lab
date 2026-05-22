#!/bin/bash
# Problem 046: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE_STAGING="cka-q046-staging"
NAMESPACE_PROD="cka-q046-prod"
PASS=0
TOTAL=0

check_cluster

# Task 1: Staging Deployment 확인 (1 replica)
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE_STAGING" get deployment kustom-app &>/dev/null; then
  REPLICAS=$(kubectl -n "$NAMESPACE_STAGING" get deployment kustom-app -o jsonpath='{.spec.replicas}')
  READY=$(kubectl -n "$NAMESPACE_STAGING" get deployment kustom-app -o jsonpath='{.status.readyReplicas}')
  if [ "$REPLICAS" = "1" ] && [ "$READY" = "1" ]; then
    print_pass "Task 1: Staging Deployment 'kustom-app' (1 replica Running)"
    PASS=$((PASS+1))
  else
    print_fail "Task 1: Staging Deployment 스펙 불일치 (replicas=$REPLICAS, ready=$READY)" \
      "staging은 1 replica여야 합니다"
  fi
else
  print_fail "Task 1: Staging Deployment 'kustom-app' 미생성" \
    "kubectl apply -k /tmp/kustomize/overlays/staging 실행"
fi

# Task 2: Prod Deployment 확인 (3 replicas)
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE_PROD" get deployment kustom-app &>/dev/null; then
  REPLICAS=$(kubectl -n "$NAMESPACE_PROD" get deployment kustom-app -o jsonpath='{.spec.replicas}')
  READY=$(kubectl -n "$NAMESPACE_PROD" get deployment kustom-app -o jsonpath='{.status.readyReplicas}')
  if [ "$REPLICAS" = "3" ] && [ "$READY" = "3" ]; then
    print_pass "Task 2: Prod Deployment 'kustom-app' (3 replicas Running)"
    PASS=$((PASS+1))
  else
    print_fail "Task 2: Prod Deployment 스펙 불일치 (replicas=$REPLICAS, ready=$READY)" \
      "prod는 3 replicas여야 합니다"
  fi
else
  print_fail "Task 2: Prod Deployment 'kustom-app' 미생성" \
    "kubectl apply -k /tmp/kustomize/overlays/prod 실행"
fi

# Task 3: Staging Service 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE_STAGING" get svc kustom-app-svc &>/dev/null; then
  print_pass "Task 3: Staging Service 'kustom-app-svc' 존재"
  PASS=$((PASS+1))
else
  print_fail "Task 3: Staging Service 'kustom-app-svc' 미생성" \
    "base에 service.yaml을 포함하세요"
fi

# Task 4: Prod Service 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE_PROD" get svc kustom-app-svc &>/dev/null; then
  print_pass "Task 4: Prod Service 'kustom-app-svc' 존재"
  PASS=$((PASS+1))
else
  print_fail "Task 4: Prod Service 'kustom-app-svc' 미생성" \
    "base에 service.yaml을 포함하세요"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
