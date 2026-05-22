#!/bin/bash
# Problem 055: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q055"
PASS=0
TOTAL=0

check_cluster

# Task 1: ResourceQuota 존재 및 설정 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get resourcequota ns-quota &>/dev/null; then
  PODS_HARD=$(kubectl -n "$NAMESPACE" get resourcequota ns-quota -o jsonpath='{.spec.hard.pods}' 2>/dev/null)
  MEM_HARD=$(kubectl -n "$NAMESPACE" get resourcequota ns-quota -o jsonpath='{.spec.hard.limits\.memory}' 2>/dev/null)
  CPU_HARD=$(kubectl -n "$NAMESPACE" get resourcequota ns-quota -o jsonpath='{.spec.hard.limits\.cpu}' 2>/dev/null)
  # requests 기준으로도 확인
  if [ -z "$MEM_HARD" ]; then
    MEM_HARD=$(kubectl -n "$NAMESPACE" get resourcequota ns-quota -o jsonpath='{.spec.hard.requests\.memory}' 2>/dev/null)
  fi
  if [ -z "$CPU_HARD" ]; then
    CPU_HARD=$(kubectl -n "$NAMESPACE" get resourcequota ns-quota -o jsonpath='{.spec.hard.requests\.cpu}' 2>/dev/null)
  fi
  if [ "$PODS_HARD" = "4" ] && [ "$MEM_HARD" = "2Gi" ] && [ "$CPU_HARD" = "2" ]; then
    print_pass "Task 1: ResourceQuota 'ns-quota' 올바르게 설정됨 (pods=4, memory=2Gi, cpu=2)"
    PASS=$((PASS+1))
  else
    print_fail "Task 1: ResourceQuota 설정 불일치 (pods=$PODS_HARD, memory=$MEM_HARD, cpu=$CPU_HARD)" \
      "pods: 4, memory: 2Gi, cpu: 2 확인"
  fi
else
  print_fail "Task 1: ResourceQuota 'ns-quota' 미생성" "kubectl -n $NAMESPACE apply로 생성하세요"
fi

# Task 2: LimitRange 존재 및 설정 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get limitrange ns-limitrange &>/dev/null; then
  DEFAULT_MEM=$(kubectl -n "$NAMESPACE" get limitrange ns-limitrange -o jsonpath='{.spec.limits[0].default.memory}' 2>/dev/null)
  DEFAULT_CPU=$(kubectl -n "$NAMESPACE" get limitrange ns-limitrange -o jsonpath='{.spec.limits[0].default.cpu}' 2>/dev/null)
  DEFAULT_REQ_MEM=$(kubectl -n "$NAMESPACE" get limitrange ns-limitrange -o jsonpath='{.spec.limits[0].defaultRequest.memory}' 2>/dev/null)
  DEFAULT_REQ_CPU=$(kubectl -n "$NAMESPACE" get limitrange ns-limitrange -o jsonpath='{.spec.limits[0].defaultRequest.cpu}' 2>/dev/null)
  if [ "$DEFAULT_MEM" = "256Mi" ] && [ "$DEFAULT_CPU" = "250m" ] && [ "$DEFAULT_REQ_MEM" = "128Mi" ] && [ "$DEFAULT_REQ_CPU" = "100m" ]; then
    print_pass "Task 2: LimitRange 'ns-limitrange' 올바르게 설정됨"
    PASS=$((PASS+1))
  else
    print_fail "Task 2: LimitRange 설정 불일치 (limits: mem=$DEFAULT_MEM cpu=$DEFAULT_CPU, requests: mem=$DEFAULT_REQ_MEM cpu=$DEFAULT_REQ_CPU)" \
      "default: 256Mi/250m, defaultRequest: 128Mi/100m 확인"
  fi
else
  print_fail "Task 2: LimitRange 'ns-limitrange' 미생성" "kubectl -n $NAMESPACE apply로 생성하세요"
fi

# Task 3: Deployment 존재 및 3 replicas 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get deployment quota-test &>/dev/null; then
  REPLICAS=$(kubectl -n "$NAMESPACE" get deployment quota-test -o jsonpath='{.spec.replicas}')
  READY=$(kubectl -n "$NAMESPACE" get deployment quota-test -o jsonpath='{.status.readyReplicas}')
  if [ "$REPLICAS" = "3" ] && [ "$READY" = "3" ]; then
    print_pass "Task 3: Deployment 'quota-test' 3 replicas Running"
    PASS=$((PASS+1))
  else
    print_fail "Task 3: Deployment 상태 불일치 (replicas=$REPLICAS, ready=$READY)" \
      "LimitRange가 있으면 리소스가 자동 설정됩니다"
  fi
else
  print_fail "Task 3: Deployment 'quota-test' 미생성" "kubectl -n $NAMESPACE create deployment으로 생성하세요"
fi

# Task 4: ResourceQuota 사용량 확인
TOTAL=$((TOTAL+1))
PODS_USED=$(kubectl -n "$NAMESPACE" get resourcequota ns-quota -o jsonpath='{.status.used.pods}' 2>/dev/null)
if [ -n "$PODS_USED" ] && [ "$PODS_USED" -ge 3 ]; then
  print_pass "Task 4: ResourceQuota 사용량 정상 (pods used=$PODS_USED/4)"
  PASS=$((PASS+1))
else
  print_fail "Task 4: ResourceQuota 사용량 확인 불가 (pods used=$PODS_USED)" \
    "kubectl -n $NAMESPACE describe resourcequota ns-quota로 확인"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
