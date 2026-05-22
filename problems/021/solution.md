# Problem 021: 정답 풀이

## Step 1: 각 Pod의 QoS 클래스 확인

```bash
kubectl -n cka-q021 get pod pod-guaranteed -o jsonpath='{.status.qosClass}'
# 출력: Guaranteed

kubectl -n cka-q021 get pod pod-burstable -o jsonpath='{.status.qosClass}'
# 출력: Burstable

kubectl -n cka-q021 get pod pod-besteffort -o jsonpath='{.status.qosClass}'
# 출력: BestEffort
```

## Step 2: QoS 종료 우선순위 분석

메모리 압박 시 kubelet의 Pod 종료 순서:
1. **BestEffort** - 리소스 requests/limits가 없는 Pod (가장 먼저 종료)
2. **Burstable** - requests < limits 또는 일부만 설정된 Pod
3. **Guaranteed** - requests == limits인 Pod (가장 나중에 종료)

따라서 `pod-besteffort`가 가장 먼저 종료됩니다.

## Step 3: ConfigMap 생성

```bash
kubectl -n cka-q021 create configmap qos-analysis \
  --from-literal=guaranteed=pod-guaranteed \
  --from-literal=burstable=pod-burstable \
  --from-literal=besteffort=pod-besteffort \
  --from-literal=first-terminated=pod-besteffort \
  --from-literal=eviction-order="BestEffort -> Burstable -> Guaranteed"
```

## 검증

```bash
kubectl -n cka-q021 get configmap qos-analysis -o yaml
```
