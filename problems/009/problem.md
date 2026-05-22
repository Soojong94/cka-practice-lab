# Problem 009: projected Volume (여러 소스 결합)

| 항목 | 값 |
|------|-----|
| 문제 번호 | 009 |
| 도메인 | Configuration |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 12분 |
| 네임스페이스 | cka-q009 |

## Context

네임스페이스 `cka-q009`에 ServiceAccount `app-sa`, ConfigMap `app-config`, Secret `app-secret`이 이미 생성되어 있습니다.

애플리케이션이 여러 설정 소스를 단일 디렉토리에서 접근해야 합니다. projected 볼륨을 사용하여 이 세 가지 소스를 하나의 마운트 포인트에 결합하세요.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. 네임스페이스 `cka-q009`에 다음 리소스가 존재하는지 확인하세요:
   - ServiceAccount: `app-sa`
   - ConfigMap: `app-config` (키: `app.properties`)
   - Secret: `app-secret` (키: `api-key`)

2. 다음 스펙으로 Pod를 생성하세요:
   - 이름: `projected-pod`
   - 이미지: `busybox:1.36`
   - 명령: `sleep 3600`
   - ServiceAccount: `app-sa`

3. projected 볼륨을 구성하여 `/etc/projected` 경로에 마운트하세요. 다음 소스를 포함:
   - ServiceAccount 토큰 (path: `token`, expirationSeconds: 3600)
   - ConfigMap `app-config` (items: `app.properties` → path: `config/app.properties`)
   - Secret `app-secret` (items: `api-key` → path: `secrets/api-key`)

4. Pod 내부에서 `/etc/projected/token` 파일이 존재하는지 확인하세요.

5. Pod 내부에서 `/etc/projected/config/app.properties`와 `/etc/projected/secrets/api-key` 파일 내용을 확인하세요.

## Expected Outcome

- Pod `projected-pod`가 Running 상태
- `/etc/projected/token` 파일 존재 (ServiceAccount 토큰)
- `/etc/projected/config/app.properties` 파일에 ConfigMap 내용
- `/etc/projected/secrets/api-key` 파일에 Secret 내용

<details>
<summary>힌트 1</summary>

projected 볼륨은 여러 볼륨 소스를 하나의 디렉토리에 결합합니다. `serviceAccountToken`, `configMap`, `secret` 소스를 하나의 projected 볼륨에 정의합니다.

</details>

<details>
<summary>힌트 2</summary>

```yaml
volumes:
- name: projected-vol
  projected:
    sources:
    - serviceAccountToken:
        path: token
        expirationSeconds: 3600
    - configMap:
        name: app-config
        items:
        - key: app.properties
          path: config/app.properties
    - secret:
        name: app-secret
        items:
        - key: api-key
          path: secrets/api-key
```

</details>

<details>
<summary>힌트 3</summary>

검증 명령:
```bash
kubectl -n cka-q009 exec projected-pod -- ls -la /etc/projected/
kubectl -n cka-q009 exec projected-pod -- cat /etc/projected/config/app.properties
kubectl -n cka-q009 exec projected-pod -- cat /etc/projected/secrets/api-key
```

</details>
