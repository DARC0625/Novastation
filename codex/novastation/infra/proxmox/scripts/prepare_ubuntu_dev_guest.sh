#!/usr/bin/env bash
set -euo pipefail

# Run inside an Ubuntu 22.04 guest to prep it as a dev VM with RDP support.

if [[ $EUID -ne 0 ]]; then
  echo "Run as root inside the guest" >&2
  exit 1
fi

apt-get update
apt-get install -y \
  xrdp \
  openssh-server \
  build-essential \
  curl \
  git \
  htop \
  unzip \
  python3-pip \
  python3-venv

# Node.js (LTS) via nodesource
if ! command -v node >/dev/null 2>&1; then
  curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
  apt-get install -y nodejs
fi

# Docker + Compose
if ! command -v docker >/dev/null 2>&1; then
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
    > /etc/apt/sources.list.d/docker.list
  apt-get update
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  usermod -aG docker ${SUDO_USER:-${USER}}
fi

# Enable and start xrdp
systemctl enable --now xrdp

# Optional: VS Code Server
if ! command -v code-server >/dev/null 2>&1; then
  curl -fsSL https://code-server.dev/install.sh | sh
  systemctl enable --now code-server@$SUDO_USER || true
fi

echo "Dev VM prepared. Configure RDP firewall rules as needed."
