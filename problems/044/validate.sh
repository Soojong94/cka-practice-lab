#!/bin/bash
# Problem 044: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q044"
PASS=0
TOTAL=0

check_cluster

# Task 1: prod-app 존재 및 toleration 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get pod prod-app &>/dev/null; then
  TOLERATIONS=$(kubectl -n "$NAMESPACE" get pod prod-app -o jsonpath='{.spec.tolerations}' 2>/dev/null)
  if echo "$TOLERATIONS" | grep -q '"key":"env"' || echo "$TOLERATIONS" | grep -q '"key": "env"'; then
    print_pass "Task 1: prod-app에 env toleration 설정됨"
    PASS=$((PASS+1))
  else
    # JSON 형식 차이 대응
    TOL_KEY=$(kubectl -n "$NAMESPACE" get pod prod-app -o json 2>/dev/null | grep -o '"key":"env"' | head -1)
    if [ -n "$TOL_KEY" ]; then
      print_pass "Task 1: prod-app에 env toleration 설정됨"
      PASS=$((PASS+1))
    else
      print_fail "Task 1: prod-app에 env toleration 미설정" \
        "tolerations에 key: env, value: production, effect: NoSchedule 추가"
    fi
  fi
else
  print_fail "Task 1: Pod 'prod-app' 미생성" "kubectl -n $NAMESPACE apply로 생성하세요"
fi

# Task 2: dev-app 존재 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get pod dev-app &>/dev/null; then
  print_pass "Task 2: Pod 'dev-app' 생성됨"
  PASS=$((PASS+1))
else
  print_fail "Task 2: Pod 'dev-app' 미생성" "toleration 없이 Pod를 생성하세요"
fi

# Task 3: Taint 제거 확인
TOTAL=$((TOTAL+1))
NODE_NAME=$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')
TAINTS=$(kubectl get node "$NODE_NAME" -o jsonpath='{.spec.taints}' 2>/dev/null)
if echo "$TAINTS" | grep -q "env"; then
  print_fail "Task 3: 노드에 env taint가 아직 존재함" \
    "kubectl taint nodes $NODE_NAME env=production:NoSchedule- 으로 제거"
else
  print_pass "Task 3: 노드에서 env taint 제거됨"
  PASS=$((PASS+1))
fi

# Task 4: 두 Pod 모두 Running 확인
TOTAL=$((TOTAL+1))
PROD_STATUS=$(kubectl -n "$NAMESPACE" get pod prod-app -o jsonpath='{.status.phase}' 2>/dev/null)
DEV_STATUS=$(kubectl -n "$NAMESPACE" get pod dev-app -o jsonpath='{.status.phase}' 2>/dev/null)
if [ "$PROD_STATUS" = "Running" ] && [ "$DEV_STATUS" = "Running" ]; then
  print_pass "Task 4: 두 Pod 모두 Running 상태"
  PASS=$((PASS+1))
else
  print_fail "Task 4: Pod 상태 불일치 (prod-app=$PROD_STATUS, dev-app=$DEV_STATUS)" \
    "taint 제거 후 잠시 대기하면 dev-app도 Running이 됩니다"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
