# Problem 006: ConfigMap을 Volume으로 마운트

| 항목 | 값 |
|------|-----|
| 문제 번호 | 006 |
| 도메인 | Configuration |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 8분 |
| 네임스페이스 | cka-q006 |

## Context

네임스페이스 `cka-q006`에 `web-server`라는 Deployment(nginx)가 동작 중입니다. 또한 `nginx-config`라는 ConfigMap이 이미 생성되어 있으며, 커스텀 nginx 설정 파일(`custom.conf`)을 포함하고 있습니다.

현재 nginx는 기본 설정으로 동작하고 있으며, ConfigMap의 설정을 적용해야 합니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. ConfigMap `nginx-config`의 내용을 확인하세요.
   - `custom.conf` 키에 nginx 서버 설정이 포함되어 있어야 합니다.

2. Deployment `web-server`를 수정하여 ConfigMap `nginx-config`를 볼륨으로 마운트하세요:
   - 마운트 경로: `/etc/nginx/conf.d/`
   - 볼륨 이름: `config-volume`

3. Deployment의 Pod가 재시작되어 새 설정이 적용되었는지 확인하세요.

4. nginx가 커스텀 설정으로 응답하는지 확인하세요:
   - Pod 내부에서 `curl localhost` 실행 시 `Hello from CKA ConfigMap Lab!` 응답

5. ConfigMap이 `/etc/nginx/conf.d/custom.conf` 파일로 마운트되었는지 확인하세요.

## Expected Outcome

- Deployment `web-server`에 ConfigMap 볼륨이 마운트됨
- `/etc/nginx/conf.d/custom.conf` 파일이 존재
- nginx가 `Hello from CKA ConfigMap Lab!` 메시지로 응답

<details>
<summary>힌트 1</summary>

ConfigMap을 볼륨으로 마운트하면 각 키가 파일명이 되고, 값이 파일 내용이 됩니다. `custom.conf` 키는 `/etc/nginx/conf.d/custom.conf` 파일로 마운트됩니다.

</details>

<details>
<summary>힌트 2</summary>

```yaml
spec:
  template:
    spec:
      volumes:
      - name: config-volume
        configMap:
          name: nginx-config
      containers:
      - name: nginx
        volumeMounts:
        - name: config-volume
          mountPath: /etc/nginx/conf.d/
```

</details>

<details>
<summary>힌트 3</summary>

`kubectl -n cka-q006 edit deployment web-server`로 직접 편집하거나 patch 명령을 사용하세요. 변경 후 Pod가 자동으로 재시작됩니다.

nginx 기본 이미지에는 curl이 없으므로 `wget -qO- localhost` 또는 별도 Pod에서 테스트하세요.

</details>
