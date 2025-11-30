#!/usr/bin/env bash
set -euo pipefail

# Create base VM templates on Proxmox for dev (Ubuntu) and GPU (Windows 11) workloads.
# Adjust storage names, bridges, and ISO paths for your environment.

require_root() {
  if [[ $EUID -ne 0 ]]; then
    echo "Run as root on the Proxmox host" >&2
    exit 1
  fi
}

STORAGE=${STORAGE:-local-lvm}       # Proxmox storage name
BRIDGE=${BRIDGE:-vmbr0}
UBUNTU_ISO=${UBUNTU_ISO:-/var/lib/vz/template/iso/ubuntu-22.04.4-live-server-amd64.iso}
WINDOWS_ISO=${WINDOWS_ISO:-/var/lib/vz/template/iso/Win11_23H2_English_x64v2.iso}
VIRTIO_ISO=${VIRTIO_ISO:-/var/lib/vz/template/iso/virtio-win.iso}   # for Windows drivers

UBUNTU_TEMPLATE_ID=${UBUNTU_TEMPLATE_ID:-9000}
WINDOWS_TEMPLATE_ID=${WINDOWS_TEMPLATE_ID:-9001}

create_ubuntu_template() {
  qm create "$UBUNTU_TEMPLATE_ID" \
    --name vm-dev-template \
    --memory 16384 --cores 4 --sockets 1 --cpu host \
    --net0 virtio,bridge="$BRIDGE" \
    --scsihw virtio-scsi-pci --scsi0 "$STORAGE":100 \
    --ide2 "$STORAGE":cloudinit \
    --serial0 socket --vga serial0 \
    --agent enabled=1,fstrim_cloned_disks=1 \
    --ostype l26

  qm set "$UBUNTU_TEMPLATE_ID" --boot c --bootdisk scsi0
  qm set "$UBUNTU_TEMPLATE_ID" --ipconfig0 ip=dhcp
  qm set "$UBUNTU_TEMPLATE_ID" --sshkeys ~/.ssh/id_rsa.pub || true
  qm set "$UBUNTU_TEMPLATE_ID" --iso "$UBUNTU_ISO"

  echo "Ubuntu template created: VMID=$UBUNTU_TEMPLATE_ID"
  echo "Install OS, enable xrdp/ssh, then convert to template: qm template $UBUNTU_TEMPLATE_ID"
}

create_windows_template() {
  qm create "$WINDOWS_TEMPLATE_ID" \
    --name vm-gpu-template \
    --memory 65536 --cores 12 --sockets 1 --cpu host \
    --net0 virtio,bridge="$BRIDGE" \
    --scsihw virtio-scsi-pci --scsi0 "$STORAGE":1024 \
    --machine q35 \
    --bios ovmf \
    --efidisk0 "$STORAGE":0,pre-enrolled-keys=1 \
    --agent enabled=1 \
    --ostype win11

  qm set "$WINDOWS_TEMPLATE_ID" --boot c --bootdisk scsi0
  qm set "$WINDOWS_TEMPLATE_ID" --ide2 "$STORAGE":iso/"$(basename "$WINDOWS_ISO")",media=cdrom
  qm set "$WINDOWS_TEMPLATE_ID" --sata0 "$VIRTIO_ISO",media=cdrom

  echo "Windows template created: VMID=$WINDOWS_TEMPLATE_ID"
  echo "Install OS, add VirtIO drivers, enable RDP, then convert to template: qm template $WINDOWS_TEMPLATE_ID"
  echo "Add GPU passthrough devices after cloning instances (qm set <id> --hostpci0 0000:65:00)"
}

main() {
  require_root
  create_ubuntu_template
  create_windows_template
}

main "$@"
