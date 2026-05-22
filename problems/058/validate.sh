#!/bin/bash
# Problem 058: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q058"
PASS=0
TOTAL=0

check_cluster

# Task 1: ClusterRole 존재 및 스펙 확인
TOTAL=$((TOTAL+1))
if kubectl get clusterrole node-viewer &>/dev/null; then
  VERBS=$(kubectl get clusterrole node-viewer -o jsonpath='{.rules[0].verbs[*]}')
  RESOURCES=$(kubectl get clusterrole node-viewer -o jsonpath='{.rules[0].resources[*]}')
  if echo "$VERBS" | grep -q "get" && echo "$VERBS" | grep -q "list" && echo "$VERBS" | grep -q "watch" && \
     echo "$RESOURCES" | grep -q "nodes" && echo "$RESOURCES" | grep -q "namespaces"; then
    print_pass "Task 1: ClusterRole 'node-viewer' 올바르게 생성됨"
    PASS=$((PASS+1))
  else
    print_fail "Task 1: ClusterRole 'node-viewer' 스펙 불일치 (verbs: $VERBS, resources: $RESOURCES)" \
      "get,list,watch 동작과 nodes,namespaces 리소스를 확인하세요"
  fi
else
  print_fail "Task 1: ClusterRole 'node-viewer' 미생성" \
    "kubectl create clusterrole 명령을 사용하세요"
fi

# Task 2: ClusterRoleBinding 존재 및 스펙 확인
TOTAL=$((TOTAL+1))
if kubectl get clusterrolebinding node-viewer-binding &>/dev/null; then
  ROLE_REF=$(kubectl get clusterrolebinding node-viewer-binding -o jsonpath='{.roleRef.name}')
  SUBJECT_NAME=$(kubectl get clusterrolebinding node-viewer-binding -o jsonpath='{.subjects[0].name}')
  SUBJECT_NS=$(kubectl get clusterrolebinding node-viewer-binding -o jsonpath='{.subjects[0].namespace}')
  if [ "$ROLE_REF" = "node-viewer" ] && [ "$SUBJECT_NAME" = "cluster-viewer" ] && [ "$SUBJECT_NS" = "cka-q058" ]; then
    print_pass "Task 2: ClusterRoleBinding 'node-viewer-binding' 올바르게 생성됨"
    PASS=$((PASS+1))
  else
    print_fail "Task 2: ClusterRoleBinding 스펙 불일치 (roleRef: $ROLE_REF, subject: $SUBJECT_NAME@$SUBJECT_NS)" \
      "clusterrole과 serviceaccount 참조를 확인하세요"
  fi
else
  print_fail "Task 2: ClusterRoleBinding 'node-viewer-binding' 미생성" \
    "kubectl create clusterrolebinding 명령을 사용하세요"
fi

# Task 3: can-list-nodes 확인
TOTAL=$((TOTAL+1))
CAN_LIST_NODES=$(kubectl -n "$NAMESPACE" get configmap cluster-rbac-verify -o jsonpath='{.data.can-list-nodes}' 2>/dev/null)
if [ "$CAN_LIST_NODES" = "yes" ]; then
  print_pass "Task 3: can-list-nodes = yes 올바르게 저장됨"
  PASS=$((PASS+1))
else
  print_fail "Task 3: can-list-nodes 값 불일치 (현재: '$CAN_LIST_NODES')" \
    "kubectl auth can-i list nodes --as=system:serviceaccount:cka-q058:cluster-viewer"
fi

# Task 4: can-list-namespaces 확인
TOTAL=$((TOTAL+1))
CAN_LIST_NS=$(kubectl -n "$NAMESPACE" get configmap cluster-rbac-verify -o jsonpath='{.data.can-list-namespaces}' 2>/dev/null)
if [ "$CAN_LIST_NS" = "yes" ]; then
  print_pass "Task 4: can-list-namespaces = yes 올바르게 저장됨"
  PASS=$((PASS+1))
else
  print_fail "Task 4: can-list-namespaces 값 불일치 (현재: '$CAN_LIST_NS')" \
    "ClusterRole은 모든 네임스페이스에서 동작합니다"
fi

# Task 5: can-delete-pods 확인
TOTAL=$((TOTAL+1))
CAN_DELETE=$(kubectl -n "$NAMESPACE" get configmap cluster-rbac-verify -o jsonpath='{.data.can-delete-pods}' 2>/dev/null)
if [ "$CAN_DELETE" = "no" ]; then
  print_pass "Task 5: can-delete-pods = no 올바르게 저장됨"
  PASS=$((PASS+1))
else
  print_fail "Task 5: can-delete-pods 값 불일치 (현재: '$CAN_DELETE')" \
    "node-viewer role에는 pods delete 권한이 없습니다"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
