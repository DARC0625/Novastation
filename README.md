# NovaStation

Infrastructure and portal scaffolding to run Proxmox-based developer/3D VMs and expose them via Apache Guacamole so low-spec clients can access them through the browser.

## Layout
- `codex/novastation/infra/proxmox/` — Proxmox host setup (PCI passthrough) and VM template scripts.
- `codex/novastation/infra/guacamole/` — Docker Compose stack for Guacamole and optional Nginx reverse proxy.
- `codex/novastation/portal/backend/` — FastAPI skeleton for user/VM mapping and Guac link API.
- `codex/novastation/portal/frontend/` — React/Vite dashboard skeleton.

## Quick start (summary)
1) On the Proxmox host: run passthrough script → reboot → create VM templates → clone VMs → enable RDP/xrdp in guests.
2) On the Guacamole VM: fill `.env`, init DB, `docker compose up -d`, create RDP connections per VM.
3) (Optional) Portal: set `.env` for backend/frontend, run backend with Uvicorn, frontend with Vite; replace mock auth/data with real integrations.

Detailed steps and commands are inside each subdirectory README.
