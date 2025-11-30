# NovaStation 리포 개요

이 저장소는 NovaStation 인프라/포털 코드를 담고 있습니다. 실제 소스와 스크립트, 상세 가이드는 `novastation/` 폴더 아래에 있습니다(기본 GitHub 화면에는 이 파일이 먼저 보입니다).

## 폴더 안내
- `novastation/README.md` — 전체 아키텍처/설치 절차/보안 체크리스트 상세 설명.
- `novastation/infra/` — Proxmox 설정, VM 템플릿 스크립트, Guacamole Docker Compose, Nginx 예제.
- `novastation/portal/` — FastAPI 백엔드와 React/Vite 프런트 대시보드 뼈대.

## 빠른 시작
1) [novastation/README.md](novastation/README.md) 읽기(아키텍처, 준비물, 보안, 단계별 설치 정리).
2) Proxmox 호스트: 패스스루 스크립트 실행 → 재부팅 → 템플릿/클론 생성 → 게스트에서 RDP 활성화.
3) Guacamole VM: `.env` 작성 후 Docker Compose로 스택 기동 → VM별 RDP 연결 생성.
4) (선택) 포털: 백엔드/프런트 `.env` 설정 후 실행 → 실제 인증·DB 연동으로 교체.
