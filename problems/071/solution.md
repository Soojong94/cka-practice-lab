# Problem 071: 정답 풀이

## Step 1: 현재 ConfigMap 확인

```bash
kubectl -n cka-q071 get configmap webhook-config -o yaml
```

## Step 2: 수정된 ConfigMap 적용

```bash
kubectl apply -n cka-q071 -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: webhook-config
  namespace: cka-q071
data:
  webhook.yaml: |
    apiVersion: admissionregistration.k8s.io/v1
    kind: ValidatingWebhookConfiguration
    metadata:
      name: pod-validation-webhook
    webhooks:
    - name: validate-pods.example.com
      admissionReviewVersions: ["v1"]
      clientConfig:
        service:
          name: webhook-service
          namespace: webhook-system
          path: "/validate"
        caBundle: LS0tLS1CRUdJTi...
      rules:
      - apiGroups: [""]
        apiVersions: ["v1"]
        operations: ["CREATE"]
        resources: ["pods"]
      failurePolicy: Ignore
      sideEffects: None
      matchPolicy: Equivalent
EOF
```

## 핵심 개념

- **ValidatingWebhookConfiguration**: API 서버에 요청이 들어올 때 외부 웹훅 서버로 유효성 검사를 위임
- **failurePolicy: Ignore**: 웹훅 서버가 응답하지 않을 때 요청을 허용 (Fail이면 거부)
- **sideEffects: None**: 웹훅이 클러스터 상태를 변경하지 않음을 선언 (dry-run 지원에 필요)
- **operations**: 어떤 API 작업을 가로챌지 지정 (CREATE, UPDATE, DELETE, CONNECT)

## 검증

```bash
kubectl -n cka-q071 get configmap webhook-config -o jsonpath='{.data.webhook\.yaml}'
```
