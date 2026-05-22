#!/bin/bash
# Problem 075: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q075"
PASS=0
TOTAL=0

check_cluster

# ConfigMap에서 값 추출
RUNTIME_VERSION=$(kubectl -n "$NAMESPACE" get configmap cri-info -o jsonpath='{.data.runtime-version}' 2>/dev/null)
RUNTIME_ENDPOINT=$(kubectl -n "$NAMESPACE" get configmap cri-info -o jsonpath='{.data.runtime-endpoint}' 2>/dev/null)
LIST_CMD=$(kubectl -n "$NAMESPACE" get configmap cri-info -o jsonpath='{.data.list-containers-command}' 2>/dev/null)
INSPECT_CMD=$(kubectl -n "$NAMESPACE" get configmap cri-info -o jsonpath='{.data.inspect-command}' 2>/dev/null)

# Task 1: runtime-version에 containerd 정보가 있는지
TOTAL=$((TOTAL+1))
if echo "$RUNTIME_VERSION" | grep -qi 'containerd'; then
  print_pass "Task 1: runtime-version에 containerd 정보 포함 ($RUNTIME_VERSION)"
  PASS=$((PASS+1))
else
  print_fail "Task 1: runtime-version에 containerd 정보 없음" "kubectl get nodes -o wide로 CONTAINER-RUNTIME 확인"
fi

# Task 2: runtime-endpoint에 containerd 소켓 경로가 있는지
TOTAL=$((TOTAL+1))
if echo "$RUNTIME_ENDPOINT" | grep -q 'unix:///run/containerd/containerd.sock'; then
  print_pass "Task 2: runtime-endpoint가 올바름 (unix:///run/containerd/containerd.sock)"
  PASS=$((PASS+1))
else
  print_fail "Task 2: runtime-endpoint가 올바르지 않음" "unix:///run/containerd/containerd.sock으로 설정하세요"
fi

# Task 3: list-containers-command에 crictl ps가 있는지
TOTAL=$((TOTAL+1))
if echo "$LIST_CMD" | grep -q 'crictl.*ps'; then
  print_pass "Task 3: list-containers-command에 crictl ps 포함"
  PASS=$((PASS+1))
else
  print_fail "Task 3: list-containers-command에 crictl ps 없음" "crictl ps 명령어를 기록하세요"
fi

# Task 4: inspect-command에 crictl inspect가 있는지
TOTAL=$((TOTAL+1))
if echo "$INSPECT_CMD" | grep -q 'crictl.*inspect'; then
  print_pass "Task 4: inspect-command에 crictl inspect 포함"
  PASS=$((PASS+1))
else
  print_fail "Task 4: inspect-command에 crictl inspect 없음" "crictl inspect <CONTAINER_ID> 형식을 기록하세요"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
