# Problem 060: 정답 풀이

## Step 1: Pod 생성

```bash
kubectl -n cka-q060 apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: api-pod
spec:
  serviceAccountName: api-reader
  containers:
  - name: curl
    image: curlimages/curl:latest
    command: ["sleep", "3600"]
EOF
```

## Step 2: Pod Ready 대기

```bash
kubectl -n cka-q060 wait --for=condition=Ready pod/api-pod --timeout=60s
```

## Step 3: Pod 내부에서 API 호출

```bash
# Pod 내부에서 실행
kubectl -n cka-q060 exec api-pod -- sh -c '
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
curl -s --cacert $CACERT -H "Authorization: Bearer $TOKEN" \
  https://kubernetes.default.svc/api/v1/namespaces/cka-q060/secrets
'
```

## Step 4: Secret 이름 추출 및 응답 코드 확인

```bash
# Secret 이름 추출
SECRET_NAMES=$(kubectl -n cka-q060 exec api-pod -- sh -c '
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
curl -s --cacert $CACERT -H "Authorization: Bearer $TOKEN" \
  https://kubernetes.default.svc/api/v1/namespaces/cka-q060/secrets | \
  grep -o "\"name\": *\"[^\"]*\"" | cut -d\" -f4 | tr "\n" "," | sed "s/,$//"
')

# 응답 코드 확인
RESPONSE_CODE=$(kubectl -n cka-q060 exec api-pod -- sh -c '
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
curl -s -o /dev/null -w "%{http_code}" --cacert $CACERT -H "Authorization: Bearer $TOKEN" \
  https://kubernetes.default.svc/api/v1/namespaces/cka-q060/secrets
')

# ConfigMap 생성
kubectl -n cka-q060 create configmap api-result \
  --from-literal=secret-names="$SECRET_NAMES" \
  --from-literal=response-code="$RESPONSE_CODE"
```

## 검증

```bash
kubectl -n cka-q060 get configmap api-result -o yaml
```
