# NovaStation

브라우저만으로 Proxmox 기반 개발/3D용 VM에 접속하게 해 주는 인프라·포털 뼈대입니다. 로컬 저사양 클라이언트(4~6GB RAM 등)에서 서버(i9-13900/192GB/RTX 3090)의 VM을 RDP로 사용하도록 구성합니다.

## 목표
- 서버에서 VM 리소스를 관리하고, 클라이언트는 화면 스트리밍+입력만 처리.
- 개발용(Ubuntu/Windows)과 GPU 패스스루 3D용 VM을 공존.
- Apache Guacamole을 통해 웹 RDP 접속을 단일 진입점으로 제공.

## 주요 기능
- Proxmox에서 VM 템플릿 생성 및 GPU(3090) PCI 패스스루 준비 스크립트 제공.
- Ubuntu 게스트용 RDP(xrdp)/개발 스택 자동 설치 스크립트 제공.
- Guacamole + Postgres Docker Compose 스택, Nginx 리버스 프록시 예제.
- (선택) FastAPI 백엔드 + React/Vite 프런트 대시보드 뼈대.

## 사용 도구
- 하이퍼바이저: Proxmox VE (KVM/QEMU)
- 원격 게이트웨이: Apache Guacamole (Docker Compose)
- 웹/프록시: Nginx (HTTPS 종단)
- 백엔드: FastAPI, PostgreSQL
- 프런트엔드: React + Vite

## 개발 방향/로드맵
- 1차(MVP): Proxmox 템플릿 생성 → VM 클론 → 게스트 RDP 활성화 → Guacamole로 접속 관리.
- 2차: 포털 백엔드/프런트에 실제 인증(SSO/JWT)과 사용자별 VM 매핑 연동.
- 3차: 모니터링/로그(접속 기록, 리소스 사용), 자동화(Ansible/Proxmox API), 보안 강화를 위한 정책 적용.

## 디렉터리 구성
- `codex/novastation/infra/proxmox/` — Proxmox 호스트 설정(PCI 패스스루)과 VM 템플릿 스크립트.
- `codex/novastation/infra/guacamole/` — Guacamole + Postgres Docker Compose, Nginx 예제.
- `codex/novastation/portal/backend/` — FastAPI 스켈레톤(유저/VM 매핑, Guac 링크 API).
- `codex/novastation/portal/frontend/` — React/Vite 대시보드 스켈레톤.

## 빠른 시작(요약)
1) Proxmox 호스트: 패스스루 스크립트 실행 → 재부팅 → 템플릿 생성 → VM 클론 → 게스트 RDP/xrdp 활성화.
2) Guacamole VM: `.env` 작성 → DB 스키마 init → `docker compose up -d` → VM별 RDP 연결 생성.
3) (선택) 포털: 백엔드/프런트 `.env` 설정 → Uvicorn/Vite 실행 → 실제 인증·DB 연동으로 대체.

세부 명령과 절차는 각 하위 README에 있습니다.
