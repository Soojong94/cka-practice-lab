#!/bin/bash
# Problem 045: 풀이 검증
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"

NAMESPACE="cka-q045"
PASS=0
TOTAL=0

check_cluster

# Task 1: Pod static-web 존재 및 스펙 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get pod static-web &>/dev/null; then
  IMAGE=$(kubectl -n "$NAMESPACE" get pod static-web -o jsonpath='{.spec.containers[0].image}')
  LABEL=$(kubectl -n "$NAMESPACE" get pod static-web -o jsonpath='{.metadata.labels.role}')
  PORT=$(kubectl -n "$NAMESPACE" get pod static-web -o jsonpath='{.spec.containers[0].ports[0].containerPort}')
  if [ "$IMAGE" = "nginx:1-alpine" ] && [ "$LABEL" = "static-web" ] && [ "$PORT" = "80" ]; then
    print_pass "Task 1: Pod 'static-web' 올바르게 생성됨 (image=nginx:1-alpine, label=static-web, port=80)"
    PASS=$((PASS+1))
  else
    print_fail "Task 1: Pod 스펙 불일치 (image=$IMAGE, label=$LABEL, port=$PORT)" \
      "image: nginx:1-alpine, label: role=static-web, containerPort: 80 확인"
  fi
else
  print_fail "Task 1: Pod 'static-web' 미생성" "kubectl -n $NAMESPACE apply로 생성하세요"
fi

# Task 2: ConfigMap 존재 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get configmap static-pod-manifest &>/dev/null; then
  CM_KEY=$(kubectl -n "$NAMESPACE" get configmap static-pod-manifest -o jsonpath='{.data}' 2>/dev/null)
  if echo "$CM_KEY" | grep -q "static-web"; then
    print_pass "Task 2: ConfigMap 'static-pod-manifest'에 매니페스트 저장됨"
    PASS=$((PASS+1))
  else
    print_fail "Task 2: ConfigMap에 static-web 매니페스트 내용 없음" \
      "static-web.yaml 키로 Pod 매니페스트를 저장하세요"
  fi
else
  print_fail "Task 2: ConfigMap 'static-pod-manifest' 미생성" \
    "kubectl -n $NAMESPACE create configmap으로 생성하세요"
fi

# Task 3: NodePort Service 존재 확인
TOTAL=$((TOTAL+1))
if kubectl -n "$NAMESPACE" get svc static-web-svc &>/dev/null; then
  SVC_TYPE=$(kubectl -n "$NAMESPACE" get svc static-web-svc -o jsonpath='{.spec.type}')
  SVC_PORT=$(kubectl -n "$NAMESPACE" get svc static-web-svc -o jsonpath='{.spec.ports[0].port}')
  SVC_SELECTOR=$(kubectl -n "$NAMESPACE" get svc static-web-svc -o jsonpath='{.spec.selector.role}')
  if [ "$SVC_TYPE" = "NodePort" ] && [ "$SVC_PORT" = "80" ] && [ "$SVC_SELECTOR" = "static-web" ]; then
    print_pass "Task 3: NodePort Service 'static-web-svc' 올바르게 생성됨"
    PASS=$((PASS+1))
  else
    print_fail "Task 3: Service 스펙 불일치 (type=$SVC_TYPE, port=$SVC_PORT, selector=$SVC_SELECTOR)" \
      "type: NodePort, port: 80, selector: role=static-web 확인"
  fi
else
  print_fail "Task 3: Service 'static-web-svc' 미생성" \
    "kubectl -n $NAMESPACE expose 또는 apply로 Service를 생성하세요"
fi

# Task 4: Pod Running 및 Service 연결 확인
TOTAL=$((TOTAL+1))
POD_STATUS=$(kubectl -n "$NAMESPACE" get pod static-web -o jsonpath='{.status.phase}' 2>/dev/null)
ENDPOINTS=$(kubectl -n "$NAMESPACE" get endpoints static-web-svc -o jsonpath='{.subsets[0].addresses}' 2>/dev/null)
if [ "$POD_STATUS" = "Running" ] && [ -n "$ENDPOINTS" ]; then
  print_pass "Task 4: Pod Running 및 Service 엔드포인트 연결됨"
  PASS=$((PASS+1))
else
  print_fail "Task 4: Pod 또는 Service 연결 문제 (status=$POD_STATUS, endpoints=$ENDPOINTS)" \
    "Pod가 Running이고 Service selector가 Pod 레이블과 일치하는지 확인"
fi

# 최종 점수
print_score $PASS $TOTAL

if [ $PASS -eq $TOTAL ]; then
  exit 0
else
  exit 1
fi
