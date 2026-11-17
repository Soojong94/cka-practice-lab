# Problem 000: 환경 설정 가이드

| 항목 | 값 |
|------|-----|
| 문제 번호 | 000 |
| 도메인 | Setup Guide |
| 난이도 | - |
| 예상 소요 시간 | 10분 |
| 네임스페이스 | - |

## 사전 요구사항

이 연습 환경을 사용하려면 아래 소프트웨어가 설치되어 있어야 합니다.

### 1. Docker Desktop 설치

- [Docker Desktop 다운로드](https://www.docker.com/products/docker-desktop/)
- Windows, macOS 모두 지원

### 2. Kubernetes 활성화

Docker Desktop 설치 후:

1. Docker Desktop 실행
2. **Settings** (⚙️) 클릭
3. **Kubernetes** 탭 선택
4. **Enable Kubernetes** 체크
5. **Apply & Restart** 클릭
6. 좌측 하단에 Kubernetes 아이콘이 초록색이 되면 준비 완료

### 3. kubectl 확인

Docker Desktop이 kubectl을 자동 설치합니다. 터미널에서 확인:

```bash
kubectl version
kubectl get nodes
```

`docker-desktop` 노드가 `Ready` 상태여야 합니다.

### 4. Node.js 설치 (웹 UI용)

- [Node.js 다운로드](https://nodejs.org/) (LTS 버전 권장)
- 설치 후 확인:

```bash
node --version   # v18 이상
npm --version
```

### 5. Git Bash 설치 (Windows만 해당)

- [Git for Windows 다운로드](https://git-scm.com/download/win)
- 설치 시 기본 옵션 유지
- 설치 후 `C:\Program Files\Git\bin\bash.exe` 존재 확인

macOS/Linux는 기본 bash를 사용하므로 별도 설치 불필요.

### 6. 프로젝트 클론 및 실행

```bash
# 1. 저장소 클론
git clone https://github.com/soojong94/cka-practice-lab.git
cd cka-practice-lab

# 2. 의존성 설치
npm install

# 3. 웹 UI 실행
npm start

# 4. 브라우저에서 열기
# http://localhost:3000
```

### 7. kubectl context 확인

```bash
kubectl config current-context
# 출력: docker-desktop

# 만약 다른 context라면:
kubectl config use-context docker-desktop
```

### 8. 클러스터 상태 확인

```bash
kubectl get nodes
# NAME             STATUS   ROLES           AGE   VERSION
# docker-desktop   Ready    control-plane   ...   v1.x.x

kubectl get pods -A
# kube-system 네임스페이스에 시스템 Pod들이 Running이어야 합니다
```

## 사용 방법

1. 웹 UI (`http://localhost:3000`)에서 문제 선택
2. **Setup** 버튼 클릭 → 클러스터에 환경 세팅
3. **본인 터미널**에서 `kubectl` 명령어로 문제 풀기
4. **Validate** 버튼 클릭 → 채점 결과 확인
5. **Cleanup** 버튼 클릭 → 환경 정리
6. 다음 문제로 이동

## 권장 Docker Desktop 리소스 설정

- **CPU**: 2코어 이상
- **Memory**: 4GB 이상
- **Disk**: 20GB 이상

Settings > Resources에서 조정 가능합니다.

## 트러블슈팅

### kubectl 연결 안 됨
```bash
# Docker Desktop Kubernetes가 활성화되어 있는지 확인
# Docker Desktop 트레이 아이콘 > Kubernetes 상태 확인
kubectl cluster-info
```

### Setup 스크립트 실행 안 됨 (Windows)
```bash
# Git Bash가 설치되어 있는지 확인
"C:\Program Files\Git\bin\bash.exe" --version
```

### 네임스페이스 삭제가 안 됨
```bash
# 강제 삭제
kubectl delete ns <namespace> --grace-period=0 --force
```

### Pod가 ImagePullBackOff
```bash
# 인터넷 연결 확인 (이미지 최초 pull 시 필요)
docker pull nginx:1-alpine
```
