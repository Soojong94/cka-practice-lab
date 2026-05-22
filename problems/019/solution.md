# Problem 019: 정답 풀이

## Step 1: Service 및 Endpoints 확인

```bash
kubectl -n cka-q019 get svc web-svc
kubectl -n cka-q019 get endpoints web-svc
kubectl -n cka-q019 describe svc web-svc
```

Endpoints가 `<none>`임을 확인합니다.

## Step 2: Pod 라벨 확인

```bash
kubectl -n cka-q019 get pods --show-labels
```

Pod의 라벨이 `app=web`임을 확인합니다.

## Step 3: Service selector 확인

```bash
kubectl -n cka-q019 get svc web-svc -o jsonpath='{.spec.selector}'
```

selector가 `{"app":"webapp"}`으로 되어 있어 Pod 라벨 `app=web`과 불일치합니다.

## Step 4: Service selector 수정

```bash
kubectl -n cka-q019 patch svc web-svc -p '{"spec":{"selector":{"app":"web"}}}'
```

또는:
```bash
kubectl -n cka-q019 edit svc web-svc
# spec.selector.app: webapp → spec.selector.app: web
```

## Step 5: 수정 확인

```bash
kubectl -n cka-q019 get endpoints web-svc
# IP 주소가 표시되는지 확인
```

## 검증

```bash
kubectl -n cka-q019 run curl-test --image=curlimages/curl:8.4.0 --restart=Never --rm -it -- curl -s http://web-svc.cka-q019.svc.cluster.local
```
