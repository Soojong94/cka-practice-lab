# Problem 079: 정답 풀이

## Step 1: 현재 감사 정책 확인

```bash
kubectl -n cka-q079 get configmap audit-policy -o jsonpath='{.data.policy\.yaml}'
```

## Step 2: 완성된 감사 정책 적용

```bash
kubectl -n cka-q079 apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: audit-policy
  namespace: cka-q079
data:
  policy.yaml: |
    apiVersion: audit.k8s.io/v1
    kind: Policy
    rules:
    # Rule 1: Secrets에 대한 모든 요청을 RequestResponse 레벨로 기록
    - level: RequestResponse
      resources:
      - group: ""
        resources: ["secrets"]
    # Rule 2: Namespace 변경을 Metadata 레벨로 기록
    - level: Metadata
      resources:
      - group: ""
        resources: ["namespaces"]
      verbs: ["create", "update", "delete"]
    # Rule 3: ConfigMap 읽기를 무시
    - level: None
      resources:
      - group: ""
        resources: ["configmaps"]
      verbs: ["get", "list", "watch"]
EOF
```

## 핵심 개념

- **Audit Policy**: API 서버가 어떤 이벤트를 어떤 수준으로 기록할지 정의
- **레벨**:
  - `None`: 기록하지 않음
  - `Metadata`: 요청 메타데이터만 (사용자, 시간, 리소스, 동작)
  - `Request`: 메타데이터 + 요청 본문
  - `RequestResponse`: 메타데이터 + 요청 본문 + 응답 본문
- **규칙 순서**: 첫 번째 매칭되는 규칙이 적용됨 (순서 중요)
- **verbs**: 특정 동작만 필터링 (get, list, watch, create, update, patch, delete)

## API 서버에 감사 정책 적용 방법 (참고)

```yaml
# /etc/kubernetes/manifests/kube-apiserver.yaml에 추가
spec:
  containers:
  - command:
    - kube-apiserver
    - --audit-policy-file=/etc/kubernetes/audit/policy.yaml
    - --audit-log-path=/var/log/kubernetes/audit.log
    - --audit-log-maxage=30
    - --audit-log-maxbackup=10
```

## 검증

```bash
kubectl -n cka-q079 get configmap audit-policy -o jsonpath='{.data.policy\.yaml}'
```
