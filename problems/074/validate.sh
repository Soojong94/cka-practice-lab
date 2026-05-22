#!/bin/bash
# Problem 074: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q074"
PASS=0
TOTAL=0

check_cluster

# ConfigMap에서 kubelet config 추출
CONFIG_YAML=$(kubectl -n "$NAMESPACE" get configmap kubelet-config -o jsonpath='{.data.config\.yaml}' 2>/dev/null)

# Task 1: clusterDNS가 10.96.0.10으로 수정되었는지
TOTAL=$((TOTAL+1))
if echo "$CONFIG_YAML" | grep -q '10\.96\.0\.10'; then
  print_pass "Task 1: clusterDNS가 10.96.0.10으로 수정됨"
  PASS=$((PASS+1))
else
  print_fail "Task 1: clusterDNS가 10.96.0.10이 아님" "clusterDNS를 10.96.0.10으로 수정하세요"
fi

# Task 2: staticPodPath가 /etc/kubernetes/manifests로 수정되었는지
TOTAL=$((TOTAL+1))
if echo "$CONFIG_YAML" | grep -q 'staticPodPath:.*/etc/kubernetes/manifests'; then
  print_pass "Task 2: staticPodPath가 /etc/kubernetes/manifests로 수정됨"
  PASS=$((PASS+1))
else
  print_fail "Task 2: staticPodPath가 올바르지 않음" "staticPodPath를 /etc/kubernetes/manifests로 수정하세요"
fi

# Task 3: authentication.anonymous.enabled가 false인지
TOTAL=$((TOTAL+1))
# YAML에서 anonymous 섹션 아래 enabled: false 확인
if echo "$CONFIG_YAML" | grep -A2 'anonymous:' | grep -q 'enabled:.*false'; then
  print_pass "Task 3: authentication.anonymous.enabled가 false로 수정됨"
  PASS=$((PASS+1))
else
  print_fail "Task 3: authentication.anonymous.enabled가 false가 아님" "anonymous.enabled를 false로 수정하세요"
fi

# Task 4: authentication.webhook.enabled가 true인지
TOTAL=$((TOTAL+1))
if echo "$CONFIG_YAML" | grep -A2 'webhook:' | grep -q 'enabled:.*true'; then
  print_pass "Task 4: authentication.webhook.enabled가 true로 설정됨"
  PASS=$((PASS+1))
else
  print_fail "Task 4: authentication.webhook.enabled가 true가 아님" "webhook.enabled: true를 추가하세요"
fi

# Task 5: authorization.mode가 Webhook인지
TOTAL=$((TOTAL+1))
if echo "$CONFIG_YAML" | grep -q 'mode:.*Webhook'; then
  print_pass "Task 5: authorization.mode가 Webhook으로 설정됨"
  PASS=$((PASS+1))
else
  print_fail "Task 5: authorization.mode가 Webhook이 아님" "authorization.mode: Webhook을 추가하세요"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
