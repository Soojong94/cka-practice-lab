#!/bin/bash
# Problem 064: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q064"
PASS=0
TOTAL=0

check_cluster

# Task 1: CRD 존재 확인
TOTAL=$((TOTAL+1))
if kubectl get crd databases.stable.example.com &>/dev/null; then
  print_pass "Task 1: CRD 'databases.stable.example.com' 존재"
  PASS=$((PASS+1))
else
  print_fail "Task 1: CRD 'databases.stable.example.com' 미생성" \
    "apiextensions.k8s.io/v1 CustomResourceDefinition을 생성하세요"
fi

# Task 2: CRD 스펙 확인 (scope, kind)
TOTAL=$((TOTAL+1))
CRD_SCOPE=$(kubectl get crd databases.stable.example.com -o jsonpath='{.spec.scope}' 2>/dev/null)
CRD_KIND=$(kubectl get crd databases.stable.example.com -o jsonpath='{.spec.names.kind}' 2>/dev/null)
if [ "$CRD_SCOPE" = "Namespaced" ] && [ "$CRD_KIND" = "Database" ]; then
  print_pass "Task 2: CRD 스펙 올바름 (Namespaced, Kind=Database)"
  PASS=$((PASS+1))
else
  print_fail "Task 2: CRD 스펙 불일치 (scope: $CRD_SCOPE, kind: $CRD_KIND)" \
    "scope: Namespaced, kind: Database 확인"
fi

# Task 3: Custom Resource 존재 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get database my-postgres &>/dev/null; then
  print_pass "Task 3: Custom Resource 'my-postgres' 존재"
  PASS=$((PASS+1))
else
  print_fail "Task 3: Custom Resource 'my-postgres' 미생성" \
    "apiVersion: stable.example.com/v1, kind: Database로 CR을 생성하세요"
fi

# Task 4: CR spec 필드 확인
TOTAL=$((TOTAL+1))
DB_NAME=$(kubectl -n "$NAMESPACE" get database my-postgres -o jsonpath='{.spec.databaseName}' 2>/dev/null)
DB_VERSION=$(kubectl -n "$NAMESPACE" get database my-postgres -o jsonpath='{.spec.version}' 2>/dev/null)
DB_REPLICAS=$(kubectl -n "$NAMESPACE" get database my-postgres -o jsonpath='{.spec.replicas}' 2>/dev/null)
if [ "$DB_NAME" = "postgres" ] && [ "$DB_VERSION" = "15.4" ] && [ "$DB_REPLICAS" = "3" ]; then
  print_pass "Task 4: CR spec 필드 올바름 (postgres, 15.4, 3)"
  PASS=$((PASS+1))
else
  print_fail "Task 4: CR spec 필드 불일치 (name: $DB_NAME, version: $DB_VERSION, replicas: $DB_REPLICAS)" \
    "databaseName: postgres, version: 15.4, replicas: 3"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
