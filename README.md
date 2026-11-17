# ☸️ CKA Practice Lab

**killer.sh 수준의 CKA(Certified Kubernetes Administrator) 시험 대비 연습 환경**

Docker Desktop 로컬 쿠버네티스 클러스터에서 100개의 실전 문제를 풀 수 있습니다.

## 빠른 시작

```bash
# 1. 클론
git clone https://github.com/soojong94/cka-practice-lab.git
cd cka-practice-lab

# 2. 의존성 설치
npm install

# 3. 웹 UI 실행
npm start

# 4. 브라우저 열기
# http://localhost:3000
```

## 사전 요구사항

- **Docker Desktop** + Kubernetes 활성화
- **Node.js** v18+
- **Git Bash** (Windows) 또는 bash (macOS/Linux)
- **kubectl** (Docker Desktop이 자동 설치)

자세한 설정 방법은 웹 UI에서 **Problem 000**을 참고하세요.

## 사용 방법

1. 웹 UI에서 문제 선택
2. **Setup** 클릭 → 클러스터에 환경 세팅
3. 본인 터미널에서 `kubectl`로 문제 풀기
4. **Validate** 클릭 → 자동 채점
5. **Cleanup** 클릭 → 환경 정리

## 문제 구성 (100문제)

| 도메인 | 문제 번호 | 개수 | 비중 |
|--------|-----------|------|------|
| Storage | 001~010 | 10 | 10% |
| Troubleshooting | 011~040 | 30 | 30% |
| Workloads & Scheduling | 041~055 | 15 | 15% |
| Cluster Architecture | 056~080 | 25 | 25% |
| Services & Networking | 081~100 | 20 | 20% |

2025년 2월 CKA 커리큘럼 업데이트 반영:
- Gateway API
- Helm / Kustomize
- CRD / Operator
- CNI / CSI / CRI 확장 인터페이스

## 디렉토리 구조

```
cka-practice-lab/
├── server.js              # 웹 서버
├── public/index.html      # 웹 UI
├── shared/common.sh       # 공통 스크립트 함수
├── problems/
│   ├── 000/               # 환경 설정 가이드
│   ├── 001/               # PV/PVC 생성 및 Pod 마운트
│   │   ├── setup.sh       # 환경 세팅
│   │   ├── problem.md     # 문제 설명
│   │   ├── validate.sh    # 풀이 검증
│   │   ├── cleanup.sh     # 환경 정리
│   │   └── solution.md    # 정답 풀이
│   └── ...
└── cleanup-all.sh         # 전체 환경 정리
```

## 권장 Docker Desktop 설정

- CPU: 2코어 이상
- Memory: 4GB 이상
- Kubernetes: 활성화

## License

MIT
