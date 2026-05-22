#!/bin/bash
# Problem 057: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q057"
PASS=0
TOTAL=0

check_cluster

# Task 1: Role 존재 및 스펙 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get role developer-role &>/dev/null; then
  VERBS=$(kubectl -n "$NAMESPACE" get role developer-role -o jsonpath='{.rules[0].verbs[*]}')
  RESOURCES=$(kubectl -n "$NAMESPACE" get role developer-role -o jsonpath='{.rules[0].resources[*]}')
  if echo "$VERBS" | grep -q "get" && echo "$VERBS" | grep -q "list" && echo "$VERBS" | grep -q "watch" && \
     echo "$RESOURCES" | grep -q "pods" && echo "$RESOURCES" | grep -q "configmaps"; then
    print_pass "Task 1: Role 'developer-role' 올바르게 생성됨"
    PASS=$((PASS+1))
  else
    print_fail "Task 1: Role 'developer-role' 스펙 불일치 (verbs: $VERBS, resources: $RESOURCES)" \
      "get,list,watch 동작과 pods,configmaps 리소스를 확인하세요"
  fi
else
  print_fail "Task 1: Role 'developer-role' 미생성" \
    "kubectl create role 명령을 사용하세요"
fi

# Task 2: RoleBinding 존재 및 스펙 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get rolebinding developer-binding &>/dev/null; then
  ROLE_REF=$(kubectl -n "$NAMESPACE" get rolebinding developer-binding -o jsonpath='{.roleRef.name}')
  SUBJECT_NAME=$(kubectl -n "$NAMESPACE" get rolebinding developer-binding -o jsonpath='{.subjects[0].name}')
  SUBJECT_KIND=$(kubectl -n "$NAMESPACE" get rolebinding developer-binding -o jsonpath='{.subjects[0].kind}')
  if [ "$ROLE_REF" = "developer-role" ] && [ "$SUBJECT_NAME" = "developer" ] && [ "$SUBJECT_KIND" = "ServiceAccount" ]; then
    print_pass "Task 2: RoleBinding 'developer-binding' 올바르게 생성됨"
    PASS=$((PASS+1))
  else
    print_fail "Task 2: RoleBinding 'developer-binding' 스펙 불일치 (roleRef: $ROLE_REF, subject: $SUBJECT_KIND/$SUBJECT_NAME)" \
      "roleRef와 subject를 확인하세요"
  fi
else
  print_fail "Task 2: RoleBinding 'developer-binding' 미생성" \
    "kubectl create rolebinding 명령을 사용하세요"
fi

# Task 3: can-list-pods 확인
TOTAL=$((TOTAL+1))
CAN_LIST=$(kubectl -n "$NAMESPACE" get configmap rbac-verify -o jsonpath='{.data.can-list-pods}' 2>/dev/null)
if [ "$CAN_LIST" = "yes" ]; then
  print_pass "Task 3: can-list-pods = yes 올바르게 저장됨"
  PASS=$((PASS+1))
else
  print_fail "Task 3: can-list-pods 값 불일치 (현재: '$CAN_LIST')" \
    "kubectl auth can-i list pods --as=system:serviceaccount:cka-q057:developer 결과를 저장하세요"
fi

# Task 4: can-delete-pods 확인
TOTAL=$((TOTAL+1))
CAN_DELETE=$(kubectl -n "$NAMESPACE" get configmap rbac-verify -o jsonpath='{.data.can-delete-pods}' 2>/dev/null)
if [ "$CAN_DELETE" = "no" ]; then
  print_pass "Task 4: can-delete-pods = no 올바르게 저장됨"
  PASS=$((PASS+1))
else
  print_fail "Task 4: can-delete-pods 값 불일치 (현재: '$CAN_DELETE')" \
    "kubectl auth can-i delete pods --as=system:serviceaccount:cka-q057:developer 결과를 저장하세요"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
