#!/bin/bash
# Problem 053: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q053"
PASS=0
TOTAL=0

check_cluster

# Task 1: app-pod 존재 및 initContainer 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get pod app-pod &>/dev/null; then
  INIT_NAME=$(kubectl -n "$NAMESPACE" get pod app-pod -o jsonpath='{.spec.initContainers[0].name}' 2>/dev/null)
  INIT_IMAGE=$(kubectl -n "$NAMESPACE" get pod app-pod -o jsonpath='{.spec.initContainers[0].image}' 2>/dev/null)
  if [ "$INIT_NAME" = "wait-for-db" ] && [ "$INIT_IMAGE" = "busybox" ]; then
    print_pass "Task 1: app-pod에 initContainer 'wait-for-db' 설정됨"
    PASS=$((PASS+1))
  else
    print_fail "Task 1: initContainer 불일치 (name=$INIT_NAME, image=$INIT_IMAGE)" \
      "initContainers에 name: wait-for-db, image: busybox 설정"
  fi
else
  print_fail "Task 1: Pod 'app-pod' 미생성" "kubectl -n $NAMESPACE apply로 생성하세요"
fi

# Task 2: initContainer 완료 확인
TOTAL=$((TOTAL+1))
INIT_STATUS=$(kubectl -n "$NAMESPACE" get pod app-pod -o jsonpath='{.status.initContainerStatuses[0].state.terminated.reason}' 2>/dev/null)
if [ "$INIT_STATUS" = "Completed" ]; then
  print_pass "Task 2: initContainer 완료됨 (Completed)"
  PASS=$((PASS+1))
else
  # Running 상태에서도 terminated가 아닐 수 있으므로 Pod phase로 확인
  POD_PHASE=$(kubectl -n "$NAMESPACE" get pod app-pod -o jsonpath='{.status.phase}' 2>/dev/null)
  if [ "$POD_PHASE" = "Running" ]; then
    print_pass "Task 2: initContainer 완료됨 (Pod Running)"
    PASS=$((PASS+1))
  else
    print_fail "Task 2: initContainer 미완료 (pod phase=$POD_PHASE)" \
      "db-service를 생성하면 nslookup이 성공하여 initContainer가 완료됩니다"
  fi
fi

# Task 3: db-service 존재 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get svc db-service &>/dev/null; then
  print_pass "Task 3: Service 'db-service' 존재"
  PASS=$((PASS+1))
else
  print_fail "Task 3: Service 'db-service' 미생성" \
    "kubectl -n $NAMESPACE create service clusterip db-service --tcp=80:80"
fi

# Task 4: app-pod Running 확인
TOTAL=$((TOTAL+1))
POD_STATUS=$(kubectl -n "$NAMESPACE" get pod app-pod -o jsonpath='{.status.phase}' 2>/dev/null)
if [ "$POD_STATUS" = "Running" ]; then
  print_pass "Task 4: app-pod Running 상태"
  PASS=$((PASS+1))
else
  print_fail "Task 4: app-pod가 Running이 아님 (현재: $POD_STATUS)" \
    "db-service 생성 후 잠시 대기하세요"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
