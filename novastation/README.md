# NovaStation

브라우저만으로 Proxmox 기반 개발/3D용 VM에 접속하게 해 주는 인프라·포털 뼈대입니다. 로컬 저사양 클라이언트(4~6GB RAM 등)에서 서버(i9-13900/192GB/RTX 3090) 자원을 RDP로 사용합니다.

## 목표
- 서버에서 VM 리소스를 관리하고, 클라이언트는 화면 스트리밍+입력만 처리.
- 개발용(Ubuntu/Windows)과 GPU 패스스루 3D용 VM 공존.
- Apache Guacamole을 통한 단일 웹 RDP 진입점 제공.

## 아키텍처 개요
- Proxmox VE: 하이퍼바이저(KVM/QEMU), VM 템플릿/클론 관리, GPU(3090) 패스스루.
- VM들: vm-dev-XX(개발용, 우분투/윈도우), vm-gpu-01(3D용, 3090 패스스루).
- Guacamole VM: guacd + guacamole + postgres (Docker Compose), 필요 시 Nginx HTTPS 역프록시.
- (선택) 포털: FastAPI 백엔드 + React/Vite 프런트, 사용자별 VM 목록/접속 링크 제공.

## 사용 도구
- 하이퍼바이저: Proxmox VE (KVM/QEMU)
- 원격 게이트웨이: Apache Guacamole (Docker Compose)
- 프록시: Nginx (HTTPS 종단)
- 백엔드: FastAPI, PostgreSQL
- 프런트엔드: React + Vite

## 디렉터리 구성
- `infra/proxmox/` — Proxmox 호스트 설정(PCI 패스스루)과 VM 템플릿 스크립트.
- `infra/guacamole/` — Guacamole + Postgres Docker Compose, Nginx 예제.
- `portal/backend/` — FastAPI 스켈레톤(유저/VM 매핑, Guac 링크 API).
- `portal/frontend/` — React/Vite 대시보드 스켈레톤.

## 준비물 체크
- Proxmox 호스트: i9-13900/192GB/RTX3090, PCI 패스스루 가능(IOMMU 지원).
- ISO: Ubuntu 22.04 서버, Windows 11, VirtIO 드라이버 ISO.
- 네트워크: Proxmox→VM, Guacamole→VM 간 RDP(3389) 통신 허용; 인터넷 노출 시 HTTPS 역프록시 도메인/TLS 준비.
- 관리자 계정/SSH 키, 강한 비밀번호, 방화벽 규칙.

## 설치/배포 절차 (상세)
1) **Proxmox 호스트**
   - `infra/proxmox/scripts/configure_passthrough.sh` (루트) 실행 → 재부팅.
   - `create_vm_templates.sh`에 스토리지/브리지/ISO 경로 맞춰 실행 → 우분투/윈도우 템플릿 생성.
   - OS 설치 후 `qm template <VMID>` → 클론 생성(vm-dev-XX, vm-gpu-01).
   - GPU VM에 `qm set <vmid> --hostpci0 <GPU PCI>`로 패스스루 추가.
2) **게스트 설정**
   - 우분투: `prepare_ubuntu_dev_guest.sh` 실행 → xrdp/ssh/docker/node 설치, 3389 허용.
   - 윈도우: RDP 활성화, VirtIO 드라이버 설치, GPU 드라이버 설치.
3) **Guacamole VM**
   - `infra/guacamole`에서 `.env.example` 복사 → 비밀번호/포트 설정.
   - Postgres/guacd 기동 후 DB 스키마 init → 전체 스택 `docker compose up -d`.
   - 웹 접속 `http://<host>:8080/guacamole/` → admin 로그인 → VM별 RDP 연결 생성/사용자 할당.
   - HTTPS 필요 시 `nginx.conf` 도메인/TLS 경로 수정 후 적용.
4) **포털(선택)**
   - 백엔드: `.env` 설정 → `uvicorn app.main:app --reload --host 0.0.0.0 --port 8000` (현재는 모의 토큰/VM 리스트, 실제 인증·DB 연동 필요).
   - 프런트: `.env` 설정 → `npm install && npm run dev -- --host 0.0.0.0 --port 5173` → 로그인 후 VM 목록/접속 버튼 확인.

## 운영/보안 체크리스트
- RDP 포트는 외부 직접 노출 금지, Guacamole VM/관리망만 접근 허용.
- Guacamole/DB/포털 비밀번호는 강하게 설정, 가능하면 SSO/JWT로 교체.
- Proxmox/게스트/컨테이너 보안 업데이트 주기적 적용, SSH 키 기반 로그인.
- 로그/모니터링: Guacamole 접속 로그, Proxmox 이벤트, 방화벽 로그 수집.
- HTTPS 필수, HSTS 등 보안 헤더 적용, 기본 계정/포트 정리.

## 로드맵
- 1차(MVP): Proxmox 템플릿 → 게스트 RDP → Guacamole 접속.
- 2차: 포털에 실제 인증/DB 연동, 사용자별 VM 매핑, Guac 토큰/SSO 연동.
- 3차: 모니터링·자동화(Ansible/Proxmox API), 리소스/접속 감사 로그 강화.

세부 명령과 옵션은 각 하위 README에 있습니다.
