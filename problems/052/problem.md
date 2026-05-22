# Problem 052: Multi-container Pod (sidecar 패턴)

| 항목 | 값 |
|------|-----|
| 문제 번호 | 052 |
| 도메인 | Workloads & Scheduling |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 10분 |
| 네임스페이스 | cka-q052 |

## Context

네임스페이스 `cka-q052`에 메인 애플리케이션과 사이드카 컨테이너를 포함하는 Multi-container Pod를 생성해야 합니다. 사이드카는 로그를 공유 볼륨에 기록하고, 메인 컨테이너는 해당 파일을 서빙합니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. 네임스페이스 `cka-q052`에 Pod `app-with-sidecar`를 생성하세요:
   - 메인 컨테이너:
     - 이름: `main-app`
     - 이미지: `nginx:1-alpine`
     - volumeMount: `/usr/share/nginx/html` (볼륨 이름: `shared-logs`)
   - 사이드카 컨테이너:
     - 이름: `sidecar`
     - 이미지: `busybox`
     - command: `["/bin/sh", "-c", "while true; do date >> /var/log/app/index.html; sleep 1; done"]`
     - volumeMount: `/var/log/app` (볼륨 이름: `shared-logs`)

2. 공유 볼륨을 설정하세요:
   - 이름: `shared-logs`
   - 타입: `emptyDir`

3. Pod가 Running 상태이고 2개의 컨테이너가 모두 Ready인지 확인하세요.

4. 사이드카가 로그를 정상적으로 기록하는지 확인하세요:
   - `kubectl -n cka-q052 exec app-with-sidecar -c main-app -- cat /usr/share/nginx/html/index.html`

## Expected Outcome

- Pod `app-with-sidecar`에 2개의 컨테이너 (main-app, sidecar)
- emptyDir 볼륨 `shared-logs`가 두 컨테이너에 마운트됨
- 사이드카가 매초 날짜를 기록하고, 메인 컨테이너에서 읽을 수 있음

<details>
<summary>힌트 1</summary>

Multi-container Pod에서 컨테이너 간 데이터 공유는 `emptyDir` 볼륨을 사용합니다. 같은 Pod 내의 컨테이너는 동일한 볼륨을 마운트할 수 있습니다.

</details>

<details>
<summary>힌트 2</summary>

```yaml
spec:
  volumes:
  - name: shared-logs
    emptyDir: {}
  containers:
  - name: main-app
    image: nginx:1-alpine
    volumeMounts:
    - name: shared-logs
      mountPath: /usr/share/nginx/html
  - name: sidecar
    image: busybox
    command: ["/bin/sh", "-c", "while true; do date >> /var/log/app/index.html; sleep 1; done"]
    volumeMounts:
    - name: shared-logs
      mountPath: /var/log/app
```

</details>

<details>
<summary>힌트 3</summary>

특정 컨테이너에서 명령 실행:
```bash
kubectl -n cka-q052 exec app-with-sidecar -c sidecar -- cat /var/log/app/index.html
kubectl -n cka-q052 exec app-with-sidecar -c main-app -- cat /usr/share/nginx/html/index.html
```

</details>
