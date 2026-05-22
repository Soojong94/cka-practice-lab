# Problem 056: 정답 풀이

## Step 1: context 이름 추출

```bash
# 모든 context 이름을 알파벳 순서로 정렬하여 추출
CONTEXTS=$(kubectl --kubeconfig=/tmp/cka-q056/kubeconfig config get-contexts -o name | sort | tr '\n' ',' | sed 's/,$//')
echo $CONTEXTS
# 출력: dev-context,prod-context,staging-context
```

## Step 2: current-context 확인

```bash
CURRENT=$(kubectl --kubeconfig=/tmp/cka-q056/kubeconfig config current-context)
echo $CURRENT
# 출력: dev-context
```

## Step 3: 인증서 Subject 추출

```bash
CERT_SUBJECT=$(kubectl --kubeconfig=/tmp/cka-q056/kubeconfig config view --raw \
  -o jsonpath='{.users[?(@.name=="dev-user")].user.client-certificate-data}' | \
  base64 -d | openssl x509 -noout -subject)
echo $CERT_SUBJECT
# 출력: subject= /CN=dev-user/O=dev-team (또는 유사한 형식)
```

## Step 4: 클러스터 수 확인

```bash
CLUSTER_COUNT=$(kubectl --kubeconfig=/tmp/cka-q056/kubeconfig config get-clusters | tail -n +2 | wc -l | tr -d ' ')
echo $CLUSTER_COUNT
# 출력: 3
```

## Step 5: ConfigMap 생성

```bash
kubectl -n cka-q056 create configmap context-info \
  --from-literal=contexts="dev-context,prod-context,staging-context" \
  --from-literal=current-context="dev-context" \
  --from-literal=cert-subject="$CERT_SUBJECT" \
  --from-literal=cluster-count="3"
```

## 검증

```bash
kubectl -n cka-q056 get configmap context-info -o yaml
```
