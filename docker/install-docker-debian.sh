#!/usr/bin/env bash
# Instala Docker Engine (docker-ce) nativo en Debian (WSL2) con systemd.
# Sustituye la integración de Docker Desktop (no usa Docker Desktop).
set -euo pipefail

# Prerrequisitos
sudo apt-get update
sudo apt-get install -y ca-certificates curl

# Clave GPG oficial de Docker
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Repositorio oficial (detecta el codename: bookworm/trixie)
. /etc/os-release
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian ${VERSION_CODENAME} stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Engine + plugins
sudo apt-get update
sudo apt-get install -y \
  docker-ce docker-ce-cli containerd.io \
  docker-buildx-plugin docker-compose-plugin

# Servicio (requiere systemd activo en /etc/wsl.conf)
sudo systemctl enable --now docker

echo "Verificando..."
docker version
docker compose version
docker buildx version
