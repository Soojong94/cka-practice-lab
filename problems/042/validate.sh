#!/bin/bash
# Problem 042: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q042"
PASS=0
TOTAL=0

check_cluster

# Task 1: Deployment 존재 여부 및 기본 스펙 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get deployment spread-app &>/dev/null; then
  REPLICAS=$(kubectl -n "$NAMESPACE" get deployment spread-app -o jsonpath='{.spec.replicas}')
  IMAGE=$(kubectl -n "$NAMESPACE" get deployment spread-app -o jsonpath='{.spec.template.spec.containers[0].image}')
  LABEL=$(kubectl -n "$NAMESPACE" get deployment spread-app -o jsonpath='{.spec.template.metadata.labels.app}')
  if [ "$REPLICAS" = "3" ] && [ "$IMAGE" = "nginx:1-alpine" ] && [ "$LABEL" = "spread-app" ]; then
    print_pass "Task 1: Deployment 'spread-app' 올바르게 생성됨 (replicas=3, image=nginx:1-alpine)"
    PASS=$((PASS+1))
  else
    print_fail "Task 1: Deployment 스펙 불일치 (replicas=$REPLICAS, image=$IMAGE, label=$LABEL)" \
      "replicas=3, image=nginx:1-alpine, label app=spread-app 확인"
  fi
else
  print_fail "Task 1: Deployment 'spread-app' 미생성" "kubectl -n $NAMESPACE create deployment 으로 생성하세요"
fi

# Task 2: Pod Anti-Affinity 설정 확인
TOTAL=$((TOTAL+1))
ANTI_AFFINITY=$(kubectl -n "$NAMESPACE" get deployment spread-app -o jsonpath='{.spec.template.spec.affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution}' 2>/dev/null)
if echo "$ANTI_AFFINITY" | grep -q "kubernetes.io/hostname"; then
  print_pass "Task 2: Pod Anti-Affinity (preferred) 올바르게 설정됨"
  PASS=$((PASS+1))
else
  print_fail "Task 2: Pod Anti-Affinity 미설정 또는 잘못됨" \
    "preferredDuringSchedulingIgnoredDuringExecution에 topologyKey: kubernetes.io/hostname 설정"
fi

# Task 3: Anti-Affinity의 labelSelector 확인
TOTAL=$((TOTAL+1))
LABEL_SELECTOR=$(kubectl -n "$NAMESPACE" get deployment spread-app -o json 2>/dev/null | grep -o '"app":"spread-app"' | head -1)
if [ -n "$LABEL_SELECTOR" ]; then
  print_pass "Task 3: labelSelector에 app=spread-app 설정됨"
  PASS=$((PASS+1))
else
  # jsonpath로 재확인
  MATCH=$(kubectl -n "$NAMESPACE" get deployment spread-app -o jsonpath='{.spec.template.spec.affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchLabels.app}' 2>/dev/null)
  if [ "$MATCH" = "spread-app" ]; then
    print_pass "Task 3: labelSelector에 app=spread-app 설정됨"
    PASS=$((PASS+1))
  else
    print_fail "Task 3: labelSelector 미설정" "matchLabels에 app: spread-app 추가"
  fi
fi

# Task 4: 모든 Pod Running 확인
TOTAL=$((TOTAL+1))
READY=$(kubectl -n "$NAMESPACE" get deployment spread-app -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
if [ "$READY" = "3" ]; then
  print_pass "Task 4: 모든 Pod Running (3/3)"
  PASS=$((PASS+1))
else
  print_fail "Task 4: Pod가 모두 Running이 아님 (ready=$READY)" \
    "preferred 규칙을 사용하면 단일 노드에서도 모든 Pod가 스케줄됩니다"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
