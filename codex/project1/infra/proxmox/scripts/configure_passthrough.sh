#!/usr/bin/env bash
set -euo pipefail

# Configure IOMMU and bind an NVIDIA RTX 3090 for PCI passthrough on Proxmox VE.
# Run as root on the Proxmox host (not inside a guest). Reboot is required after this script.

GPU_IDS="${GPU_IDS:-10de:2204,10de:1aef}"     # Adjust to your GPU+audio IDs (lspci -nn)
VFIO_PCI_ADDRESSES=(
  "${GPU_PCI:-0000:65:00.0}"
  "${GPU_AUDIO_PCI:-0000:65:00.1}"
)

append_line() {
  local file="$1" line="$2"
  grep -qxF "$line" "$file" 2>/dev/null || echo "$line" >>"$file"
}

require_root() {
  if [[ $EUID -ne 0 ]]; then
    echo "Run as root" >&2
    exit 1
  fi
}

set_iommu_kernel_params() {
  local grub=/etc/default/grub
  local vendor
  vendor=$(lscpu | awk -F: '/Vendor ID/ {gsub(/^[[:space:]]+/,"",$2); print $2}')
  local iommu_flag="intel_iommu=on iommu=pt"
  if [[ "$vendor" == "AuthenticAMD" ]]; then
    iommu_flag="amd_iommu=on iommu=pt"
  fi
  if grep -q "GRUB_CMDLINE_LINUX" "$grub"; then
    sed -i "s/GRUB_CMDLINE_LINUX=\".*\"/GRUB_CMDLINE_LINUX=\"quiet $iommu_flag\"/" "$grub"
  else
    echo "GRUB_CMDLINE_LINUX=\"quiet $iommu_flag\"" >>"$grub"
  fi
}

configure_modules() {
  local modules=/etc/modules
  append_line "$modules" "vfio"
  append_line "$modules" "vfio_iommu_type1"
  append_line "$modules" "vfio_pci"
  append_line "$modules" "vfio_virqfd"
}

configure_vfio_conf() {
  local vfio_conf=/etc/modprobe.d/vfio.conf
  echo "options vfio-pci ids=$GPU_IDS disable_vga=1" >"$vfio_conf"
  if ((${#VFIO_PCI_ADDRESSES[@]})); then
    {
      echo "softdep nvidia pre: vfio-pci"
      echo "softdep nouveau pre: vfio-pci"
    } >>"$vfio_conf"
  fi
}

blacklist_nouveau_nvidia() {
  local blk=/etc/modprobe.d/blacklist.conf
  append_line "$blk" "blacklist nouveau"
  append_line "$blk" "blacklist nvidia"
  append_line "$blk" "blacklist nvidiafb"
  append_line "$blk" "blacklist rivafb"
}

bind_devices_to_vfio() {
  local conf=/etc/modprobe.d/vfio-pci-override.conf
  : >"$conf"
  for dev in "${VFIO_PCI_ADDRESSES[@]}"; do
    echo "options vfio-pci ids=$GPU_IDS" >>"$conf"
    echo "options vfio-pci disable_vga=1" >>"$conf"
  done
}

update_boot() {
  update-initramfs -u
  update-grub
}

main() {
  require_root
  set_iommu_kernel_params
  configure_modules
  configure_vfio_conf
  blacklist_nouveau_nvidia
  bind_devices_to_vfio
  update_boot
  echo "Done. Reboot the host to apply passthrough settings." >&2
}

main "$@"
