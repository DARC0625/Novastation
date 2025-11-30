# Proxmox Setup

Helper scripts for configuring the Proxmox host (PCI passthrough) and creating base VM templates for dev and GPU workloads.

## Scripts
- `scripts/configure_passthrough.sh`: enables IOMMU and prepares RTX 3090 PCI passthrough.
- `scripts/create_vm_templates.sh`: example `qm` commands to build vm-dev and vm-gpu templates.

## Usage
1) Copy scripts to the Proxmox host and run as root from the Proxmox shell (not inside a guest).
2) Reboot after passthrough changes.
3) Run the template script, then clone templates into instances (vm-dev-01..N, vm-gpu-01).

> Review and adapt device IDs, storage names, and ISO paths before running.
