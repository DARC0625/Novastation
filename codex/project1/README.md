# Web VM Workspace Infra

Infrastructure skeleton to host developer/design VMs on Proxmox and expose them via Apache Guacamole for browser-based access from low-spec PCs.

## Components
- **Proxmox VE**: hypervisor for vm-dev and vm-gpu templates (KVM/QEMU, PCI passthrough for RTX 3090).
- **Guacamole**: web RDP gateway (Docker Compose on Ubuntu VM).
- **Optional Portal**: FastAPI backend + React frontend for user/VM mapping and a simple dashboard.

## Directory Layout
- `infra/proxmox/` — host configuration and VM template scripts.
- `infra/guacamole/` — Docker Compose stack and reverse proxy config.
- `portal/backend/` — FastAPI skeleton for user/VM mapping.
- `portal/frontend/` — React/Vite skeleton for a minimal dashboard.

## Usage (high level)
1) Install Proxmox on the host (manual). Enable IOMMU/PCI passthrough and create VM templates using `infra/proxmox/scripts`.
2) Create VM instances (`vm-gpu-01`, `vm-dev-XX`) from templates. Enable RDP/xrdp inside guests.
3) Deploy Guacamole (`infra/guacamole/docker-compose.yml`) on an Ubuntu VM (`vm-guac-01`), fronted by Nginx for HTTPS.
4) (Optional) Deploy the portal backend/frontend to provide login and VM listing, integrating with Guacamole connections.

## Notes
- Scripts are idempotent-friendly where possible, but review before running on production hosts.
- Fill in secrets (passwords, keys, domains) via `.env` files; only examples are checked in.
