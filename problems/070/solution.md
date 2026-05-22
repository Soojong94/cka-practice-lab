# Problem 070: 정답 풀이

## Step 1: 인증서 데이터 추출

```bash
CERT_DATA=$(kubectl --kubeconfig=/tmp/cka-q070/kubeconfig config view --raw \
  -o jsonpath='{.users[?(@.name=="admin-user")].user.client-certificate-data}')
```

## Step 2: Issuer 추출

```bash
ISSUER=$(echo "$CERT_DATA" | base64 -d | openssl x509 -noout -issuer | sed 's/issuer=//' | sed 's/issuer= //')
echo $ISSUER
# 출력: /CN=kubernetes-ca/O=kubernetes (또는 유사한 형식)
```

## Step 3: 만료일 추출

```bash
EXPIRY=$(echo "$CERT_DATA" | base64 -d | openssl x509 -noout -enddate | sed 's/notAfter=//')
echo $EXPIRY
# 출력: Sep 15 12:00:00 2025 GMT (예시)
```

## Step 4: Subject 추출

```bash
SUBJECT=$(echo "$CERT_DATA" | base64 -d | openssl x509 -noout -subject | sed 's/subject=//' | sed 's/subject= //')
echo $SUBJECT
# 출력: /CN=admin-user/O=system:masters
```

## Step 5: 유효성 확인

```bash
echo "$CERT_DATA" | base64 -d | openssl x509 -noout -checkend 0
if [ $? -eq 0 ]; then
  IS_VALID="true"
else
  IS_VALID="false"
fi
echo $IS_VALID
# 출력: true
```

## Step 6: ConfigMap 생성

```bash
kubectl -n cka-q070 create configmap cert-info \
  --from-literal=issuer="$ISSUER" \
  --from-literal=expiry="$EXPIRY" \
  --from-literal=subject="$SUBJECT" \
  --from-literal=is-valid="$IS_VALID"
```

## 검증

```bash
kubectl -n cka-q070 get configmap cert-info -o yaml
```
