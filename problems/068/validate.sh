#!/bin/bash
# Problem 068: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q068"
PASS=0
TOTAL=0

check_cluster

# Task 1: ResourceQuota 확인
TOTAL=$((TOTAL+1))
if kubectl -n cka-q068-team-a get resourcequota team-a-quota &>/dev/null; then
  MAX_PODS=$(kubectl -n cka-q068-team-a get resourcequota team-a-quota -o jsonpath='{.spec.hard.pods}')
  MAX_MEM_REQ=$(kubectl -n cka-q068-team-a get resourcequota team-a-quota -o jsonpath='{.spec.hard.requests\.memory}')
  if [ "$MAX_PODS" = "5" ] && [ "$MAX_MEM_REQ" = "1Gi" ]; then
    print_pass "Task 1: ResourceQuota 'team-a-quota' 올바르게 생성됨 (pods=5, memory requests=1Gi)"
    PASS=$((PASS+1))
  else
    print_fail "Task 1: ResourceQuota 스펙 불일치 (pods: $MAX_PODS, memory requests: $MAX_MEM_REQ)" \
      "pods: 5, requests.memory: 1Gi 확인"
  fi
else
  print_fail "Task 1: ResourceQuota 'team-a-quota' 미생성" \
    "cka-q068-team-a 네임스페이스에 ResourceQuota를 생성하세요"
fi

# Task 2: LimitRange 확인
TOTAL=$((TOTAL+1))
if kubectl -n cka-q068-team-b get limitrange team-b-limits &>/dev/null; then
  DEFAULT_MEM=$(kubectl -n cka-q068-team-b get limitrange team-b-limits -o jsonpath='{.spec.limits[0].default.memory}')
  DEFAULT_REQ=$(kubectl -n cka-q068-team-b get limitrange team-b-limits -o jsonpath='{.spec.limits[0].defaultRequest.memory}')
  MAX_MEM=$(kubectl -n cka-q068-team-b get limitrange team-b-limits -o jsonpath='{.spec.limits[0].max.memory}')
  if [ "$DEFAULT_MEM" = "256Mi" ] && [ "$DEFAULT_REQ" = "128Mi" ] && [ "$MAX_MEM" = "512Mi" ]; then
    print_pass "Task 2: LimitRange 'team-b-limits' 올바르게 생성됨"
    PASS=$((PASS+1))
  else
    print_fail "Task 2: LimitRange 스펙 불일치 (default: $DEFAULT_MEM, defaultRequest: $DEFAULT_REQ, max: $MAX_MEM)" \
      "default: 256Mi, defaultRequest: 128Mi, max: 512Mi"
  fi
else
  print_fail "Task 2: LimitRange 'team-b-limits' 미생성" \
    "cka-q068-team-b 네임스페이스에 LimitRange를 생성하세요"
fi

# Task 3: test-pod에 기본값 적용 확인
TOTAL=$((TOTAL+1))
POD_MEM_LIMIT=$(kubectl -n cka-q068-team-b get pod test-pod -o jsonpath='{.spec.containers[0].resources.limits.memory}' 2>/dev/null)
if [ "$POD_MEM_LIMIT" = "256Mi" ]; then
  print_pass "Task 3: Pod 'test-pod'에 기본 메모리 limit 256Mi 적용됨"
  PASS=$((PASS+1))
else
  print_fail "Task 3: Pod 'test-pod' 메모리 limit 불일치 (현재: '$POD_MEM_LIMIT')" \
    "LimitRange가 적용된 네임스페이스에서 Pod를 생성하면 기본값이 자동 적용됩니다"
fi

# Task 4: ConfigMap quota-verify 확인
TOTAL=$((TOTAL+1))
TEAM_A_PODS=$(kubectl -n "$NAMESPACE" get configmap quota-verify -o jsonpath='{.data.team-a-max-pods}' 2>/dev/null)
TEAM_B_MEM=$(kubectl -n "$NAMESPACE" get configmap quota-verify -o jsonpath='{.data.team-b-default-memory}' 2>/dev/null)
if [ "$TEAM_A_PODS" = "5" ] && [ "$TEAM_B_MEM" = "256Mi" ]; then
  print_pass "Task 4: ConfigMap 'quota-verify' 올바르게 생성됨"
  PASS=$((PASS+1))
else
  print_fail "Task 4: ConfigMap 'quota-verify' 값 불일치 (team-a-max-pods: $TEAM_A_PODS, team-b-default-memory: $TEAM_B_MEM)" \
    "team-a-max-pods=5, team-b-default-memory=256Mi"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
