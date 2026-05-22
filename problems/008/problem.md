# Problem 008: emptyDir과 initContainer 활용

| 항목 | 값 |
|------|-----|
| 문제 번호 | 008 |
| 도메인 | Workloads |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 10분 |
| 네임스페이스 | cka-q008 |

## Context

네임스페이스 `cka-q008`이 비어 있습니다. 웹 서버를 배포해야 하는데, 서버가 시작되기 전에 초기 데이터를 다운로드하여 준비해야 합니다.

initContainer를 사용하여 초기 데이터를 준비하고, emptyDir 볼륨을 통해 메인 컨테이너와 공유하는 Pod를 구성하세요.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. 네임스페이스 `cka-q008`에 다음 스펙으로 Pod를 생성하세요:
   - 이름: `web-init`
   - emptyDir 볼륨 이름: `workdir`

2. initContainer를 구성하세요:
   - 이름: `init-download`
   - 이미지: `busybox:1.36`
   - 명령: `sh -c "echo '<html><body><h1>Init Container Demo</h1></body></html>' > /work-dir/index.html"`
   - emptyDir 볼륨을 `/work-dir`에 마운트

3. 메인 컨테이너를 구성하세요:
   - 이름: `nginx`
   - 이미지: `nginx:1.25-alpine`
   - emptyDir 볼륨을 `/usr/share/nginx/html`에 마운트

4. Pod가 Running 상태이고 initContainer가 완료(Completed)되었는지 확인하세요.

5. 메인 컨테이너에서 `curl localhost` 실행 시 `Init Container Demo` 문자열이 포함된 응답을 확인하세요.

## Expected Outcome

- Pod `web-init`이 Running 상태
- initContainer `init-download`가 Completed 상태
- nginx가 initContainer가 생성한 `index.html`을 서빙

<details>
<summary>힌트 1</summary>

emptyDir 볼륨은 Pod가 생성될 때 빈 디렉토리로 시작하며, Pod 내 모든 컨테이너가 공유할 수 있습니다. initContainer가 먼저 실행되어 데이터를 준비하면, 메인 컨테이너가 이를 사용합니다.

</details>

<details>
<summary>힌트 2</summary>

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: web-init
spec:
  initContainers:
  - name: init-download
    image: busybox:1.36
    command: ["sh", "-c", "echo '<html>...</html>' > /work-dir/index.html"]
    volumeMounts:
    - name: workdir
      mountPath: /work-dir
  containers:
  - name: nginx
    image: nginx:1.25-alpine
    volumeMounts:
    - name: workdir
      mountPath: /usr/share/nginx/html
  volumes:
  - name: workdir
    emptyDir: {}
```

</details>

<details>
<summary>힌트 3</summary>

initContainer 상태 확인:
```bash
kubectl -n cka-q008 get pod web-init -o jsonpath='{.status.initContainerStatuses[0].state}'
```

nginx 응답 확인:
```bash
kubectl -n cka-q008 exec web-init -- wget -qO- http://localhost
```

</details>
