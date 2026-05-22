#!/bin/bash
# Problem 008: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q008"
PASS=0
TOTAL=0

check_cluster

# Task 1: Pod 'web-init' 존재 및 Running 상태
TOTAL=$((TOTAL+1))
POD_STATUS=$(kubectl -n "$NAMESPACE" get pod web-init -o jsonpath='{.status.phase}' 2>/dev/null)
if [ "$POD_STATUS" = "Running" ]; then
  print_pass "Task 1: Pod 'web-init' Running 상태"
  PASS=$((PASS+1))
else
  print_fail "Task 1: Pod 'web-init' Running 아님 (현재: $POD_STATUS)" \
    "Pod를 생성하고 Running 상태인지 확인하세요"
fi

# Task 2: initContainer 'init-download' 존재 및 완료 상태
TOTAL=$((TOTAL+1))
INIT_NAME=$(kubectl -n "$NAMESPACE" get pod web-init -o jsonpath='{.spec.initContainers[0].name}' 2>/dev/null)
INIT_STATE=$(kubectl -n "$NAMESPACE" get pod web-init -o jsonpath='{.status.initContainerStatuses[0].state.terminated.reason}' 2>/dev/null)
if [ "$INIT_NAME" = "init-download" ] && [ "$INIT_STATE" = "Completed" ]; then
  print_pass "Task 2: initContainer 'init-download' 완료됨 (Completed)"
  PASS=$((PASS+1))
else
  print_fail "Task 2: initContainer 상태 불일치 (name=$INIT_NAME, state=$INIT_STATE)" \
    "initContainer 이름이 'init-download'이고 정상 완료되어야 합니다"
fi

# Task 3: emptyDir 볼륨 'workdir' 설정 확인
TOTAL=$((TOTAL+1))
VOLUME_NAME=$(kubectl -n "$NAMESPACE" get pod web-init -o jsonpath='{.spec.volumes[?(@.emptyDir)].name}' 2>/dev/null)
INIT_MOUNT=$(kubectl -n "$NAMESPACE" get pod web-init -o jsonpath='{.spec.initContainers[0].volumeMounts[0].mountPath}' 2>/dev/null)
MAIN_MOUNT=$(kubectl -n "$NAMESPACE" get pod web-init -o jsonpath='{.spec.containers[0].volumeMounts[0].mountPath}' 2>/dev/null)
if [ "$VOLUME_NAME" = "workdir" ] && [ "$INIT_MOUNT" = "/work-dir" ] && [ "$MAIN_MOUNT" = "/usr/share/nginx/html" ]; then
  print_pass "Task 3: emptyDir 볼륨 'workdir' 올바르게 설정됨 (init:/work-dir, main:/usr/share/nginx/html)"
  PASS=$((PASS+1))
else
  print_fail "Task 3: emptyDir 볼륨 설정 불일치 (vol=$VOLUME_NAME, init_mount=$INIT_MOUNT, main_mount=$MAIN_MOUNT)" \
    "emptyDir 볼륨 이름 'workdir', initContainer는 /work-dir, 메인 컨테이너는 /usr/share/nginx/html에 마운트"
fi

# Task 4: 메인 컨테이너 이미지 확인
TOTAL=$((TOTAL+1))
MAIN_IMAGE=$(kubectl -n "$NAMESPACE" get pod web-init -o jsonpath='{.spec.containers[0].image}' 2>/dev/null)
MAIN_NAME=$(kubectl -n "$NAMESPACE" get pod web-init -o jsonpath='{.spec.containers[0].name}' 2>/dev/null)
if [ "$MAIN_NAME" = "nginx" ] && echo "$MAIN_IMAGE" | grep -q "nginx"; then
  print_pass "Task 4: 메인 컨테이너 'nginx' 이미지 확인 ($MAIN_IMAGE)"
  PASS=$((PASS+1))
else
  print_fail "Task 4: 메인 컨테이너 설정 불일치 (name=$MAIN_NAME, image=$MAIN_IMAGE)" \
    "메인 컨테이너 이름 'nginx', 이미지 'nginx:1.25-alpine' 확인"
fi

# Task 5: nginx가 initContainer가 생성한 파일을 서빙하는지 확인
TOTAL=$((TOTAL+1))
RESPONSE=$(kubectl -n "$NAMESPACE" exec web-init -c nginx -- wget -qO- http://localhost 2>/dev/null)
if echo "$RESPONSE" | grep -q "Init Container Demo"; then
  print_pass "Task 5: nginx가 initContainer가 생성한 index.html 서빙 확인"
  PASS=$((PASS+1))
else
  print_fail "Task 5: nginx 응답에 'Init Container Demo' 없음 (응답: $RESPONSE)" \
    "initContainer가 /work-dir/index.html을 생성하고, nginx가 /usr/share/nginx/html을 서빙해야 합니다"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
