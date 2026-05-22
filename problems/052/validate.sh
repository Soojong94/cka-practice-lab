#!/bin/bash
# Problem 052: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q052"
PASS=0
TOTAL=0

check_cluster

# Task 1: Pod 존재 및 2개 컨테이너 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get pod app-with-sidecar &>/dev/null; then
  CONTAINER_COUNT=$(kubectl -n "$NAMESPACE" get pod app-with-sidecar -o jsonpath='{.spec.containers}' | grep -o '"name"' | wc -l)
  if [ "$CONTAINER_COUNT" -eq 2 ]; then
    print_pass "Task 1: Pod 'app-with-sidecar'에 2개 컨테이너 존재"
    PASS=$((PASS+1))
  else
    print_fail "Task 1: 컨테이너 수 불일치 (현재: $CONTAINER_COUNT)" \
      "main-app과 sidecar 두 개의 컨테이너가 필요합니다"
  fi
else
  print_fail "Task 1: Pod 'app-with-sidecar' 미생성" "kubectl -n $NAMESPACE apply로 생성하세요"
fi

# Task 2: 컨테이너 이름 및 이미지 확인
TOTAL=$((TOTAL+1))
MAIN_IMAGE=$(kubectl -n "$NAMESPACE" get pod app-with-sidecar -o jsonpath='{.spec.containers[?(@.name=="main-app")].image}' 2>/dev/null)
SIDECAR_IMAGE=$(kubectl -n "$NAMESPACE" get pod app-with-sidecar -o jsonpath='{.spec.containers[?(@.name=="sidecar")].image}' 2>/dev/null)
if [ "$MAIN_IMAGE" = "nginx:1-alpine" ] && [ "$SIDECAR_IMAGE" = "busybox" ]; then
  print_pass "Task 2: 컨테이너 이미지 올바름 (main-app=nginx:1-alpine, sidecar=busybox)"
  PASS=$((PASS+1))
else
  print_fail "Task 2: 컨테이너 이미지 불일치 (main=$MAIN_IMAGE, sidecar=$SIDECAR_IMAGE)" \
    "main-app: nginx:1-alpine, sidecar: busybox 확인"
fi

# Task 3: 공유 볼륨 (emptyDir) 확인
TOTAL=$((TOTAL+1))
VOLUME_TYPE=$(kubectl -n "$NAMESPACE" get pod app-with-sidecar -o jsonpath='{.spec.volumes[?(@.name=="shared-logs")].emptyDir}' 2>/dev/null)
if [ -n "$VOLUME_TYPE" ]; then
  print_pass "Task 3: emptyDir 볼륨 'shared-logs' 존재"
  PASS=$((PASS+1))
else
  print_fail "Task 3: emptyDir 볼륨 'shared-logs' 미설정" \
    "volumes에 name: shared-logs, emptyDir: {} 추가"
fi

# Task 4: Pod Running 및 사이드카 로그 확인
TOTAL=$((TOTAL+1))
POD_STATUS=$(kubectl -n "$NAMESPACE" get pod app-with-sidecar -o jsonpath='{.status.phase}' 2>/dev/null)
if [ "$POD_STATUS" = "Running" ]; then
  # 사이드카가 로그를 기록하는지 확인
  sleep 2
  LOG_CONTENT=$(kubectl -n "$NAMESPACE" exec app-with-sidecar -c main-app -- cat /usr/share/nginx/html/index.html 2>/dev/null | head -1)
  if [ -n "$LOG_CONTENT" ]; then
    print_pass "Task 4: Pod Running, 사이드카 로그 기록 확인됨"
    PASS=$((PASS+1))
  else
    print_fail "Task 4: 사이드카 로그가 비어있음" \
      "사이드카 command와 volumeMount 경로를 확인하세요"
  fi
else
  print_fail "Task 4: Pod가 Running이 아님 (현재: $POD_STATUS)" \
    "kubectl -n $NAMESPACE describe pod app-with-sidecar로 원인 확인"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
