#!/bin/bash
# Problem 092: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q092"
PASS=0
TOTAL=0

check_cluster

# Task 1: TLS Secret 존재 및 타입 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get secret secure-tls &>/dev/null; then
  SECRET_TYPE=$(kubectl -n "$NAMESPACE" get secret secure-tls -o jsonpath='{.type}')
  if [ "$SECRET_TYPE" = "kubernetes.io/tls" ]; then
    print_pass "Task 1: Secret 'secure-tls' (type=kubernetes.io/tls) 존재"
    PASS=$((PASS+1))
  else
    print_fail "Task 1: Secret 타입 불일치 (현재: $SECRET_TYPE)" \
      "kubectl create secret tls 명령으로 생성하세요"
  fi
else
  print_fail "Task 1: Secret 'secure-tls' 미생성" \
    "TLS Secret을 생성하세요"
fi

# Task 2: Ingress 존재 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get ingress secure-ingress &>/dev/null; then
  print_pass "Task 2: Ingress 'secure-ingress' 존재"
  PASS=$((PASS+1))
else
  print_fail "Task 2: Ingress 'secure-ingress' 미생성" \
    "Ingress 리소스를 생성하세요"
fi

# Task 3: Ingress TLS 설정 확인
TOTAL=$((TOTAL+1))
TLS_HOST=$(kubectl -n "$NAMESPACE" get ingress secure-ingress -o jsonpath='{.spec.tls[0].hosts[0]}' 2>/dev/null)
TLS_SECRET=$(kubectl -n "$NAMESPACE" get ingress secure-ingress -o jsonpath='{.spec.tls[0].secretName}' 2>/dev/null)
if [ "$TLS_HOST" = "secure.example.com" ] && [ "$TLS_SECRET" = "secure-tls" ]; then
  print_pass "Task 3: TLS 설정 올바름 (host=secure.example.com, secret=secure-tls)"
  PASS=$((PASS+1))
else
  print_fail "Task 3: TLS 설정 불일치 (host=$TLS_HOST, secret=$TLS_SECRET)" \
    "tls[].hosts: secure.example.com, tls[].secretName: secure-tls 확인"
fi

# Task 4: Ingress backend 확인
TOTAL=$((TOTAL+1))
BACKEND_SVC=$(kubectl -n "$NAMESPACE" get ingress secure-ingress -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}' 2>/dev/null)
BACKEND_PORT=$(kubectl -n "$NAMESPACE" get ingress secure-ingress -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.port.number}' 2>/dev/null)
if [ "$BACKEND_SVC" = "secure-app-svc" ] && [ "$BACKEND_PORT" = "80" ]; then
  print_pass "Task 4: backend=secure-app-svc:80 올바름"
  PASS=$((PASS+1))
else
  print_fail "Task 4: backend 불일치 (svc=$BACKEND_SVC, port=$BACKEND_PORT)" \
    "backend.service.name: secure-app-svc, port.number: 80 확인"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
