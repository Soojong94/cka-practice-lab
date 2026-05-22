# Problem 020: 정답 풀이

## Step 1: 현재 NetworkPolicy 확인

```bash
kubectl -n cka-q020 get networkpolicy
kubectl -n cka-q020 describe networkpolicy deny-all-ingress
```

`deny-all-ingress` NetworkPolicy가 `role=server` Pod로의 모든 인바운드 트래픽을 차단하고 있습니다.

## Step 2: 통신 차단 확인

```bash
SERVER_IP=$(kubectl -n cka-q020 get pod server -o jsonpath='{.status.podIP}')
kubectl -n cka-q020 exec client -- curl -s --connect-timeout 3 http://${SERVER_IP}:80
# 타임아웃 발생
```

## Step 3: NetworkPolicy 수정

```bash
kubectl -n cka-q020 apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-ingress
  namespace: cka-q020
spec:
  podSelector:
    matchLabels:
      role: server
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: client
    ports:
    - protocol: TCP
      port: 80
EOF
```

## Step 4: 통신 확인

```bash
SERVER_IP=$(kubectl -n cka-q020 get pod server -o jsonpath='{.status.podIP}')
kubectl -n cka-q020 exec client -- curl -s http://${SERVER_IP}:80
# nginx 기본 페이지가 출력되면 성공
```

## 핵심 포인트

- NetworkPolicy는 `podSelector`로 대상 Pod를 선택합니다.
- `policyTypes: [Ingress]`만 있고 `ingress` 규칙이 비어있으면 모든 인바운드 차단
- `ingress.from.podSelector`로 허용할 소스 Pod를 지정
- `ingress.ports`로 허용할 포트를 지정

## 검증

```bash
kubectl -n cka-q020 get networkpolicy deny-all-ingress -o yaml
kubectl -n cka-q020 exec client -- curl -s --connect-timeout 5 http://${SERVER_IP}:80
```
