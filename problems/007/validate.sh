#!/bin/bash
# Problem 007: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q007"
PASS=0
TOTAL=0

check_cluster

# Task 1: Secret 'db-credentials' 존재 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get secret db-credentials &>/dev/null; then
  USERNAME=$(kubectl -n "$NAMESPACE" get secret db-credentials -o jsonpath='{.data.username}' | base64 -d 2>/dev/null)
  PASSWORD=$(kubectl -n "$NAMESPACE" get secret db-credentials -o jsonpath='{.data.password}' | base64 -d 2>/dev/null)
  if [ "$USERNAME" = "admin" ] && [ "$PASSWORD" = 's3cur3P@ss' ]; then
    print_pass "Task 1: Secret 'db-credentials' 올바르게 생성됨 (username=admin, password=s3cur3P@ss)"
    PASS=$((PASS+1))
  else
    print_fail "Task 1: Secret 'db-credentials' 데이터 불일치 (username=$USERNAME)" \
      "username=admin, password=s3cur3P@ss로 설정하세요"
  fi
else
  print_fail "Task 1: Secret 'db-credentials' 미생성" \
    "kubectl -n $NAMESPACE create secret generic db-credentials --from-literal=username=admin --from-literal=password='s3cur3P@ss'"
fi

# Task 2: Pod 'db-app' Running 상태 확인
TOTAL=$((TOTAL+1))
POD_STATUS=$(kubectl -n "$NAMESPACE" get pod db-app -o jsonpath='{.status.phase}' 2>/dev/null)
if [ "$POD_STATUS" = "Running" ]; then
  print_pass "Task 2: Pod 'db-app' Running 상태"
  PASS=$((PASS+1))
else
  print_fail "Task 2: Pod 'db-app' Running 아님 (현재: $POD_STATUS)" \
    "Pod를 재생성하세요"
fi

# Task 3: Secret이 /etc/secrets에 볼륨 마운트되었는지 확인
TOTAL=$((TOTAL+1))
MOUNT_PATH=$(kubectl -n "$NAMESPACE" get pod db-app -o jsonpath='{.spec.containers[0].volumeMounts[?(@.mountPath=="/etc/secrets")].mountPath}' 2>/dev/null)
SECRET_VOL=$(kubectl -n "$NAMESPACE" get pod db-app -o jsonpath='{.spec.volumes[?(@.secret.secretName=="db-credentials")].name}' 2>/dev/null)
if [ "$MOUNT_PATH" = "/etc/secrets" ] && [ -n "$SECRET_VOL" ]; then
  # 실제 파일 내용 확인
  FILE_CONTENT=$(kubectl -n "$NAMESPACE" exec db-app -- cat /etc/secrets/username 2>/dev/null)
  if [ "$FILE_CONTENT" = "admin" ]; then
    print_pass "Task 3: Secret 볼륨 마운트 확인 (/etc/secrets/username = admin)"
    PASS=$((PASS+1))
  else
    print_fail "Task 3: /etc/secrets/username 파일 내용 불일치 (내용: $FILE_CONTENT)" \
      "Secret이 올바르게 마운트되었는지 확인하세요"
  fi
else
  print_fail "Task 3: Secret 볼륨 마운트 미설정 (mount=$MOUNT_PATH, vol=$SECRET_VOL)" \
    "volumes에 secret을 추가하고 volumeMounts에 /etc/secrets 경로를 지정하세요"
fi

# Task 4: 환경변수 DB_USER 확인
TOTAL=$((TOTAL+1))
DB_USER_VAL=$(kubectl -n "$NAMESPACE" exec db-app -- sh -c 'echo $DB_USER' 2>/dev/null)
if [ "$DB_USER_VAL" = "admin" ]; then
  print_pass "Task 4: 환경변수 DB_USER=admin 설정됨"
  PASS=$((PASS+1))
else
  print_fail "Task 4: 환경변수 DB_USER 미설정 또는 불일치 (현재: $DB_USER_VAL)" \
    "env[].valueFrom.secretKeyRef를 사용하여 DB_USER를 설정하세요"
fi

# Task 5: 환경변수 DB_PASS 확인
TOTAL=$((TOTAL+1))
DB_PASS_VAL=$(kubectl -n "$NAMESPACE" exec db-app -- sh -c 'echo $DB_PASS' 2>/dev/null)
if [ "$DB_PASS_VAL" = 's3cur3P@ss' ]; then
  print_pass "Task 5: 환경변수 DB_PASS=s3cur3P@ss 설정됨"
  PASS=$((PASS+1))
else
  print_fail "Task 5: 환경변수 DB_PASS 미설정 또는 불일치 (현재: $DB_PASS_VAL)" \
    "env[].valueFrom.secretKeyRef를 사용하여 DB_PASS를 설정하세요"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
