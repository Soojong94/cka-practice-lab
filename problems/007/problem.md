# Problem 007: Secret을 Volume + 환경변수로 마운트

| 항목 | 값 |
|------|-----|
| 문제 번호 | 007 |
| 도메인 | Configuration |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 9분 |
| 네임스페이스 | cka-q007 |

## Context

네임스페이스 `cka-q007`에 데이터베이스 연결 정보를 안전하게 관리해야 합니다. 현재 `db-app`이라는 Pod가 동작 중이지만, 아직 시크릿이 연결되어 있지 않습니다.

데이터베이스 자격 증명을 Secret으로 생성하고, 볼륨 마운트와 환경변수 두 가지 방식으로 Pod에 전달해야 합니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. 네임스페이스 `cka-q007`에 다음 스펙으로 Secret을 생성하세요:
   - 이름: `db-credentials`
   - 타입: `Opaque`
   - 데이터:
     - `username`: `admin` (base64 인코딩)
     - `password`: `s3cur3P@ss` (base64 인코딩)

2. 기존 Pod `db-app`을 삭제하고, 다음 스펙으로 새 Pod를 생성하세요:
   - 이름: `db-app`
   - 이미지: `busybox:1.36`
   - 명령: `sleep 3600`
   - Secret `db-credentials`를 `/etc/secrets` 경로에 볼륨으로 마운트

3. 동일한 Pod에 환경변수도 설정하세요:
   - `DB_USER`: Secret `db-credentials`의 `username` 키에서 가져옴
   - `DB_PASS`: Secret `db-credentials`의 `password` 키에서 가져옴

4. Pod 내부에서 `/etc/secrets/username` 파일 내용이 `admin`인지 확인하세요.

5. Pod 내부에서 환경변수 `DB_USER`가 `admin`, `DB_PASS`가 `s3cur3P@ss`인지 확인하세요.

## Expected Outcome

- Secret `db-credentials` 존재
- Pod `db-app`이 Running 상태
- `/etc/secrets/username`과 `/etc/secrets/password` 파일 존재
- 환경변수 `DB_USER=admin`, `DB_PASS=s3cur3P@ss` 설정됨

<details>
<summary>힌트 1</summary>

Secret을 생성할 때 `kubectl create secret generic` 명령을 사용하면 자동으로 base64 인코딩됩니다:
```bash
kubectl -n cka-q007 create secret generic db-credentials --from-literal=username=admin --from-literal=password='s3cur3P@ss'
```

</details>

<details>
<summary>힌트 2</summary>

볼륨 마운트와 환경변수를 동시에 설정하는 Pod 스펙:
```yaml
spec:
  containers:
  - name: db-app
    env:
    - name: DB_USER
      valueFrom:
        secretKeyRef:
          name: db-credentials
          key: username
    - name: DB_PASS
      valueFrom:
        secretKeyRef:
          name: db-credentials
          key: password
    volumeMounts:
    - name: secret-vol
      mountPath: /etc/secrets
  volumes:
  - name: secret-vol
    secret:
      secretName: db-credentials
```

</details>

<details>
<summary>힌트 3</summary>

검증 명령:
```bash
kubectl -n cka-q007 exec db-app -- cat /etc/secrets/username
kubectl -n cka-q007 exec db-app -- env | grep DB_
```

</details>
