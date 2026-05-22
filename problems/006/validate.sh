#!/bin/bash
# Problem 006: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q006"
PASS=0
TOTAL=0

check_cluster

# Task 1: ConfigMap 'nginx-config' 존재 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get configmap nginx-config &>/dev/null; then
  CM_KEY=$(kubectl -n "$NAMESPACE" get configmap nginx-config -o jsonpath='{.data.custom\.conf}' 2>/dev/null)
  if [ -n "$CM_KEY" ]; then
    print_pass "Task 1: ConfigMap 'nginx-config'에 custom.conf 키 존재"
    PASS=$((PASS+1))
  else
    print_fail "Task 1: ConfigMap 'nginx-config'에 custom.conf 키 없음" \
      "ConfigMap의 data 필드를 확인하세요"
  fi
else
  print_fail "Task 1: ConfigMap 'nginx-config' 미생성" "ConfigMap을 확인하세요"
fi

# Task 2: Deployment에 ConfigMap 볼륨 마운트 설정 확인
TOTAL=$((TOTAL+1))
MOUNT_PATH=$(kubectl -n "$NAMESPACE" get deployment web-server -o jsonpath='{.spec.template.spec.containers[0].volumeMounts[?(@.mountPath=="/etc/nginx/conf.d/")].mountPath}' 2>/dev/null)
# mountPath 끝에 슬래시 없는 경우도 체크
if [ -z "$MOUNT_PATH" ]; then
  MOUNT_PATH=$(kubectl -n "$NAMESPACE" get deployment web-server -o jsonpath='{.spec.template.spec.containers[0].volumeMounts[?(@.mountPath=="/etc/nginx/conf.d")].mountPath}' 2>/dev/null)
fi
VOLUME_CM=$(kubectl -n "$NAMESPACE" get deployment web-server -o jsonpath='{.spec.template.spec.volumes[?(@.configMap.name=="nginx-config")].name}' 2>/dev/null)
if [ -n "$MOUNT_PATH" ] && [ -n "$VOLUME_CM" ]; then
  print_pass "Task 2: Deployment 'web-server'에 ConfigMap 볼륨 마운트 설정됨"
  PASS=$((PASS+1))
else
  print_fail "Task 2: Deployment 'web-server'에 ConfigMap 볼륨 마운트 미설정 (mount=$MOUNT_PATH, volume=$VOLUME_CM)" \
    "volumes에 configMap을 추가하고 volumeMounts에 /etc/nginx/conf.d/ 경로를 지정하세요"
fi

# Task 3: Pod가 Running 상태인지 확인
TOTAL=$((TOTAL+1))
POD_NAME=$(kubectl -n "$NAMESPACE" get pods -l app=web-server -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
POD_STATUS=$(kubectl -n "$NAMESPACE" get pod "$POD_NAME" -o jsonpath='{.status.phase}' 2>/dev/null)
if [ "$POD_STATUS" = "Running" ]; then
  print_pass "Task 3: Pod '$POD_NAME' Running 상태"
  PASS=$((PASS+1))
else
  print_fail "Task 3: Pod Running 아님 (현재: $POD_STATUS)" \
    "Deployment 수정 후 Pod가 정상 재시작되었는지 확인하세요"
fi

# Task 4: ConfigMap 파일이 마운트되었는지 확인
TOTAL=$((TOTAL+1))
if [ -n "$POD_NAME" ]; then
  FILE_EXISTS=$(kubectl -n "$NAMESPACE" exec "$POD_NAME" -- ls /etc/nginx/conf.d/custom.conf 2>/dev/null)
  if [ -n "$FILE_EXISTS" ]; then
    print_pass "Task 4: /etc/nginx/conf.d/custom.conf 파일 마운트 확인"
    PASS=$((PASS+1))
  else
    print_fail "Task 4: /etc/nginx/conf.d/custom.conf 파일 없음" \
      "ConfigMap 볼륨이 올바른 경로에 마운트되었는지 확인하세요"
  fi
else
  print_fail "Task 4: Pod를 찾을 수 없음" "Deployment가 정상 동작하는지 확인하세요"
fi

# Task 5: nginx가 커스텀 설정으로 응답하는지 확인
TOTAL=$((TOTAL+1))
if [ -n "$POD_NAME" ]; then
  RESPONSE=$(kubectl -n "$NAMESPACE" exec "$POD_NAME" -- wget -qO- http://localhost 2>/dev/null)
  if echo "$RESPONSE" | grep -q "Hello from CKA ConfigMap Lab"; then
    print_pass "Task 5: nginx가 커스텀 설정으로 응답 확인"
    PASS=$((PASS+1))
  else
    print_fail "Task 5: nginx 응답이 예상과 다름 (응답: $RESPONSE)" \
      "ConfigMap이 /etc/nginx/conf.d/에 마운트되면 nginx가 자동으로 로드합니다"
  fi
else
  print_fail "Task 5: Pod를 찾을 수 없음" "Deployment가 정상 동작하는지 확인하세요"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
