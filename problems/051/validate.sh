#!/bin/bash
# Problem 051: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q051"
PASS=0
TOTAL=0

check_cluster

# Task 1: Deployment 존재 및 기본 스펙 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get deployment balanced-app &>/dev/null; then
  REPLICAS=$(kubectl -n "$NAMESPACE" get deployment balanced-app -o jsonpath='{.spec.replicas}')
  IMAGE=$(kubectl -n "$NAMESPACE" get deployment balanced-app -o jsonpath='{.spec.template.spec.containers[0].image}')
  if [ "$REPLICAS" = "3" ] && [ "$IMAGE" = "nginx:1-alpine" ]; then
    print_pass "Task 1: Deployment 'balanced-app' 올바르게 생성됨 (replicas=3, image=nginx:1-alpine)"
    PASS=$((PASS+1))
  else
    print_fail "Task 1: Deployment 스펙 불일치 (replicas=$REPLICAS, image=$IMAGE)" \
      "replicas=3, image=nginx:1-alpine 확인"
  fi
else
  print_fail "Task 1: Deployment 'balanced-app' 미생성" "kubectl -n $NAMESPACE apply로 생성하세요"
fi

# Task 2: topologySpreadConstraints 설정 확인
TOTAL=$((TOTAL+1))
TOPOLOGY_KEY=$(kubectl -n "$NAMESPACE" get deployment balanced-app -o jsonpath='{.spec.template.spec.topologySpreadConstraints[0].topologyKey}' 2>/dev/null)
MAX_SKEW=$(kubectl -n "$NAMESPACE" get deployment balanced-app -o jsonpath='{.spec.template.spec.topologySpreadConstraints[0].maxSkew}' 2>/dev/null)
WHEN_UNSATISFIABLE=$(kubectl -n "$NAMESPACE" get deployment balanced-app -o jsonpath='{.spec.template.spec.topologySpreadConstraints[0].whenUnsatisfiable}' 2>/dev/null)
if [ "$TOPOLOGY_KEY" = "topology.kubernetes.io/zone" ] && [ "$MAX_SKEW" = "1" ] && [ "$WHEN_UNSATISFIABLE" = "ScheduleAnyway" ]; then
  print_pass "Task 2: topologySpreadConstraints 올바르게 설정됨 (maxSkew=1, zone, ScheduleAnyway)"
  PASS=$((PASS+1))
else
  print_fail "Task 2: topologySpreadConstraints 불일치 (key=$TOPOLOGY_KEY, skew=$MAX_SKEW, policy=$WHEN_UNSATISFIABLE)" \
    "maxSkew: 1, topologyKey: topology.kubernetes.io/zone, whenUnsatisfiable: ScheduleAnyway 확인"
fi

# Task 3: labelSelector 확인
TOTAL=$((TOTAL+1))
LABEL_MATCH=$(kubectl -n "$NAMESPACE" get deployment balanced-app -o jsonpath='{.spec.template.spec.topologySpreadConstraints[0].labelSelector.matchLabels.app}' 2>/dev/null)
if [ "$LABEL_MATCH" = "balanced-app" ]; then
  print_pass "Task 3: labelSelector에 app=balanced-app 설정됨"
  PASS=$((PASS+1))
else
  print_fail "Task 3: labelSelector 불일치 (현재: $LABEL_MATCH)" \
    "labelSelector.matchLabels.app: balanced-app 설정"
fi

# Task 4: 모든 Pod Running 확인
TOTAL=$((TOTAL+1))
READY=$(kubectl -n "$NAMESPACE" get deployment balanced-app -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
if [ "$READY" = "3" ]; then
  print_pass "Task 4: 모든 Pod Running (3/3)"
  PASS=$((PASS+1))
else
  print_fail "Task 4: Pod가 모두 Running이 아님 (ready=$READY)" \
    "ScheduleAnyway를 사용하면 단일 노드에서도 모든 Pod가 스케줄됩니다"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
