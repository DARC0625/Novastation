# NovaStation 리포 개요

이 저장소는 NovaStation 인프라/포털 코드를 담고 있습니다. 실제 소스와 스크립트는 `novastation/` 폴더 아래에 정리되어 있습니다.

## 폴더 안내
- `novastation/infra/` — Proxmox 설정, VM 템플릿 스크립트, Guacamole Docker Compose, Nginx 예제.
- `novastation/portal/` — FastAPI 백엔드와 React/Vite 프런트 대시보드 뼈대.

## 빠른 시작
1) `novastation/README.md`를 먼저 읽고, 환경별 단계(Proxmox 설정 → Guacamole 배포 → 포털 선택 적용)를 따라갑니다.
2) Proxmox 호스트에서 PCI 패스스루/템플릿 스크립트를 실행해 VM 기반을 마련합니다.
3) Guacamole VM에서 `.env` 작성 후 Docker Compose로 스택을 올리고, VM별 RDP 연결을 생성합니다.
4) (선택) 포털 백엔드/프런트 `.env` 설정 후 실행하여 사용자별 VM 리스트/접속 UI를 제공합니다.

세부 명령과 옵션은 `novastation/` 내부 README와 하위 디렉터리 README를 참고해 주세요.
