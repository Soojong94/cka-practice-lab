#!/bin/bash
# Problem 013: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q013"
PASS=0
TOTAL=0

check_cluster

# Task 1: memory-hog Pod 존재 및 Running 상태 확인
TOTAL=$((TOTAL+1))
POD_STATUS=$(kubectl -n "$NAMESPACE" get pod memory-hog -o jsonpath='{.status.phase}' 2>/dev/null)
if [ "$POD_STATUS" = "Running" ]; then
  print_pass "Task 1: Pod 'memory-hog' Running 상태"
  PASS=$((PASS+1))
else
  print_fail "Task 1: Pod 'memory-hog' Running 아님 (현재: ${POD_STATUS:-없음})" \
    "메모리 요청을 줄여서 Pod를 재생성하세요"
fi

# Task 2: memory-hog 메모리 요청 확인 (합리적인 값)
TOTAL=$((TOTAL+1))
MEM_REQ=$(kubectl -n "$NAMESPACE" get pod memory-hog -o jsonpath='{.spec.containers[0].resources.requests.memory}' 2>/dev/null)
# 100Gi가 아닌 합리적인 값인지 확인
if [ -n "$MEM_REQ" ] && [ "$MEM_REQ" != "100Gi" ]; then
  print_pass "Task 2: Pod 'memory-hog' 메모리 요청 합리적 ($MEM_REQ)"
  PASS=$((PASS+1))
else
  print_fail "Task 2: Pod 'memory-hog' 메모리 요청이 여전히 과도함 ($MEM_REQ)" \
    "메모리 요청을 64Mi 등 합리적인 값으로 수정하세요"
fi

# Task 3: node-selector-pod Pod 존재 및 Running 상태 확인
TOTAL=$((TOTAL+1))
POD_STATUS2=$(kubectl -n "$NAMESPACE" get pod node-selector-pod -o jsonpath='{.status.phase}' 2>/dev/null)
if [ "$POD_STATUS2" = "Running" ]; then
  print_pass "Task 3: Pod 'node-selector-pod' Running 상태"
  PASS=$((PASS+1))
else
  print_fail "Task 3: Pod 'node-selector-pod' Running 아님 (현재: ${POD_STATUS2:-없음})" \
    "nodeSelector를 제거하고 Pod를 재생성하세요"
fi

# Task 4: node-selector-pod에 문제가 되는 nodeSelector가 없는지 확인
TOTAL=$((TOTAL+1))
NODE_SEL=$(kubectl -n "$NAMESPACE" get pod node-selector-pod -o jsonpath='{.spec.nodeSelector.disktype}' 2>/dev/null)
if [ -z "$NODE_SEL" ] || [ "$NODE_SEL" != "superfast-nvme" ]; then
  print_pass "Task 4: Pod 'node-selector-pod' 문제 nodeSelector 제거됨"
  PASS=$((PASS+1))
else
  print_fail "Task 4: Pod 'node-selector-pod'에 여전히 잘못된 nodeSelector 존재 (disktype=$NODE_SEL)" \
    "nodeSelector를 제거하세요"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
