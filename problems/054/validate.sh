#!/bin/bash
# Problem 054: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q054"
PASS=0
TOTAL=0

check_cluster

# Task 1: StatefulSet 존재 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get statefulset web &>/dev/null; then
  print_pass "Task 1: StatefulSet 'web' 존재"
  PASS=$((PASS+1))
else
  print_fail "Task 1: StatefulSet 'web' 미존재" "setup.sh를 다시 실행하세요"
fi

# Task 2: replicas=2 확인
TOTAL=$((TOTAL+1))
REPLICAS=$(kubectl -n "$NAMESPACE" get statefulset web -o jsonpath='{.spec.replicas}' 2>/dev/null)
if [ "$REPLICAS" = "2" ]; then
  print_pass "Task 2: StatefulSet replicas=2"
  PASS=$((PASS+1))
else
  print_fail "Task 2: StatefulSet replicas 불일치 (현재: $REPLICAS, 기대: 2)" \
    "kubectl -n $NAMESPACE scale statefulset web --replicas=2"
fi

# Task 3: web-0, web-1 Running 확인
TOTAL=$((TOTAL+1))
WEB0_STATUS=$(kubectl -n "$NAMESPACE" get pod web-0 -o jsonpath='{.status.phase}' 2>/dev/null)
WEB1_STATUS=$(kubectl -n "$NAMESPACE" get pod web-1 -o jsonpath='{.status.phase}' 2>/dev/null)
if [ "$WEB0_STATUS" = "Running" ] && [ "$WEB1_STATUS" = "Running" ]; then
  print_pass "Task 3: web-0, web-1 모두 Running"
  PASS=$((PASS+1))
else
  print_fail "Task 3: Pod 상태 불일치 (web-0=$WEB0_STATUS, web-1=$WEB1_STATUS)" \
    "스케일 업 후 잠시 대기하세요"
fi

# Task 4: web-2 없음 확인 (스케일 다운됨)
TOTAL=$((TOTAL+1))
if ! kubectl -n "$NAMESPACE" get pod web-2 &>/dev/null; then
  print_pass "Task 4: web-2 삭제됨 (스케일 다운 확인)"
  PASS=$((PASS+1))
else
  WEB2_STATUS=$(kubectl -n "$NAMESPACE" get pod web-2 -o jsonpath='{.status.phase}' 2>/dev/null)
  print_fail "Task 4: web-2가 아직 존재함 (status=$WEB2_STATUS)" \
    "replicas를 2로 설정하면 web-2가 삭제됩니다"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
