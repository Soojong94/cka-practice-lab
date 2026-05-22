# Problem 011: 정답 풀이

## Step 1: Pod 상태 확인

```bash
kubectl -n cka-q011 get pod crash-pod
kubectl -n cka-q011 describe pod crash-pod
```

Events 섹션에서 컨테이너가 반복적으로 재시작되는 것을 확인할 수 있습니다.

## Step 2: 로그 확인

```bash
kubectl -n cka-q011 logs crash-pod
```

`exec: "sleeeep": executable file not found` 에러를 확인할 수 있습니다.

## Step 3: Pod YAML 추출 및 수정

```bash
kubectl -n cka-q011 get pod crash-pod -o yaml > /tmp/crash-pod.yaml
```

`/tmp/crash-pod.yaml`에서 command를 수정합니다:
- 변경 전: `["sleeeep", "3600"]`
- 변경 후: `["sleep", "3600"]`

## Step 4: Pod 재생성

```bash
kubectl -n cka-q011 delete pod crash-pod --grace-period=0 --force
kubectl -n cka-q011 apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: crash-pod
  namespace: cka-q011
  labels:
    app: crash-pod
spec:
  containers:
  - name: busybox
    image: busybox:1.36
    command: ["sleep", "3600"]
EOF
```

## 검증

```bash
kubectl -n cka-q011 get pod crash-pod
# STATUS가 Running인지 확인
```
