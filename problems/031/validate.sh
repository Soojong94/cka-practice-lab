#!/bin/bash
# Problem 031: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q031"
PASS=0
TOTAL=0

check_cluster

# Task 1: pods list 권한 확인
TOTAL=$((TOTAL+1))
CAN_LIST_PODS=$(kubectl auth can-i list pods --as=system:serviceaccount:${NAMESPACE}:app-sa -n "$NAMESPACE" 2>/dev/null)
if [ "$CAN_LIST_PODS" = "yes" ]; then
  print_pass "Task 1: ServiceAccount 'app-sa'가 pods list 권한 보유"
  PASS=$((PASS+1))
else
  print_fail "Task 1: ServiceAccount 'app-sa'가 pods list 권한 없음" \
    "Role 'app-role'에 pods list verb를 추가하세요"
fi

# Task 2: pods get 권한 유지 확인
TOTAL=$((TOTAL+1))
CAN_GET_PODS=$(kubectl auth can-i get pods --as=system:serviceaccount:${NAMESPACE}:app-sa -n "$NAMESPACE" 2>/dev/null)
if [ "$CAN_GET_PODS" = "yes" ]; then
  print_pass "Task 2: ServiceAccount 'app-sa'가 pods get 권한 유지"
  PASS=$((PASS+1))
else
  print_fail "Task 2: ServiceAccount 'app-sa'가 pods get 권한 없음" \
    "기존 pods get 권한을 유지하면서 수정하세요"
fi

# Task 3: configmaps create 권한 확인
TOTAL=$((TOTAL+1))
CAN_CREATE_CM=$(kubectl auth can-i create configmaps --as=system:serviceaccount:${NAMESPACE}:app-sa -n "$NAMESPACE" 2>/dev/null)
if [ "$CAN_CREATE_CM" = "yes" ]; then
  print_pass "Task 3: ServiceAccount 'app-sa'가 configmaps create 권한 보유"
  PASS=$((PASS+1))
else
  print_fail "Task 3: ServiceAccount 'app-sa'가 configmaps create 권한 없음" \
    "Role 'app-role'에 configmaps create verb를 추가하세요"
fi

# Task 4: RoleBinding 연결 확인
TOTAL=$((TOTAL+1))
ROLE_REF=$(kubectl -n "$NAMESPACE" get rolebinding app-rolebinding -o jsonpath='{.roleRef.name}' 2>/dev/null)
SUBJECT=$(kubectl -n "$NAMESPACE" get rolebinding app-rolebinding -o jsonpath='{.subjects[0].name}' 2>/dev/null)
if [ "$ROLE_REF" = "app-role" ] && [ "$SUBJECT" = "app-sa" ]; then
  print_pass "Task 4: RoleBinding 'app-rolebinding' 올바르게 연결됨"
  PASS=$((PASS+1))
else
  print_fail "Task 4: RoleBinding 'app-rolebinding' 연결 오류 (roleRef=$ROLE_REF, subject=$SUBJECT)" \
    "RoleBinding이 app-role과 app-sa를 연결하는지 확인하세요"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
