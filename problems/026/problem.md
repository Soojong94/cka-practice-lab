# Problem 026: 컨테이너 런타임 문제 해결

| 항목 | 값 |
|------|-----|
| 문제 번호 | 026 |
| 도메인 | Troubleshooting |
| 난이도 | killer.sh Level |
| 예상 소요 시간 | 8분 |
| 네임스페이스 | cka-q026 |

## Context

네임스페이스 `cka-q026`에 2개의 Pod가 정상 동작하지 않습니다. 각 Pod의 문제를 진단하고 수정하여 모두 Running 상태로 만들어야 합니다.

> 참고: https://kubernetes.io/docs 공식 문서를 참조할 수 있습니다.

## Tasks

1. Pod `app-crash`의 상태를 확인하세요. 이 Pod는 CrashLoopBackOff 상태입니다.
   - 원인: 잘못된 command가 설정되어 컨테이너가 즉시 종료됨
   - 수정: command를 `["/bin/sh", "-c", "sleep 3600"]`으로 변경하세요

2. Pod `app-imagepull`의 상태를 확인하세요. 이 Pod는 ImagePullBackOff 상태입니다.
   - 원인: 존재하지 않는 이미지 태그 사용
   - 수정: 이미지를 `nginx:alpine`으로 변경하세요

3. 두 Pod를 수정하여 Running 상태로 만드세요.
   - Pod를 삭제하고 올바른 스펙으로 재생성하세요.

4. 두 Pod가 모두 Running 상태인지 확인하세요.

## Expected Outcome

- Pod `app-crash`가 Running 상태
- Pod `app-imagepull`가 Running 상태
- 두 Pod 모두 READY 1/1

<details>
<summary>힌트 1</summary>

Pod 상태 확인:
```bash
kubectl -n cka-q026 get pods
kubectl -n cka-q026 describe pod app-crash
kubectl -n cka-q026 describe pod app-imagepull
```

</details>

<details>
<summary>힌트 2</summary>

Pod의 command나 image를 변경하려면 Pod를 삭제하고 재생성해야 합니다:
```bash
kubectl -n cka-q026 get pod app-crash -o yaml > /tmp/app-crash.yaml
# yaml 수정 후
kubectl -n cka-q026 delete pod app-crash
kubectl apply -f /tmp/app-crash.yaml
```

</details>

<details>
<summary>힌트 3</summary>

```bash
# app-crash 수정
kubectl -n cka-q026 delete pod app-crash --grace-period=0 --force
kubectl -n cka-q026 run app-crash --image=nginx:alpine \
  --command -- /bin/sh -c "sleep 3600"

# app-imagepull 수정
kubectl -n cka-q026 delete pod app-imagepull --grace-period=0 --force
kubectl -n cka-q026 run app-imagepull --image=nginx:alpine \
  --command -- /bin/sh -c "sleep 3600"
```

</details>
