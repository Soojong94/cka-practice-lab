#!/bin/bash
# 전체 환경 정리 - 모든 cka-q* 네임스페이스 삭제
echo "모든 CKA Practice Lab 리소스를 정리합니다..."

# cka-q로 시작하는 모든 네임스페이스 삭제
NAMESPACES=$(kubectl get ns -o name 2>/dev/null | grep "cka-q" | cut -d/ -f2)

if [ -z "$NAMESPACES" ]; then
  echo "정리할 네임스페이스가 없습니다."
else
  for ns in $NAMESPACES; do
    echo "삭제 중: $ns"
    kubectl delete ns "$ns" --grace-period=0 --force 2>/dev/null &
  done
  wait
  echo "네임스페이스 삭제 요청 완료"
fi

# cka-q로 시작하는 클러스터 범위 리소스 삭제
echo "클러스터 범위 리소스 정리 중..."
kubectl delete pv -l app.kubernetes.io/part-of=cka-practice --ignore-not-found 2>/dev/null
kubectl delete clusterrole -l app.kubernetes.io/part-of=cka-practice --ignore-not-found 2>/dev/null
kubectl delete clusterrolebinding -l app.kubernetes.io/part-of=cka-practice --ignore-not-found 2>/dev/null

echo "전체 정리 완료!"
