#!/usr/bin/env bash
# Aplica la config WSL (systemd + usuario) a /etc/wsl.conf.
# Requiere sudo. Luego reiniciar WSL con:  wsl --shutdown
set -euo pipefail

src="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/wsl.conf"

sudo cp "$src" /etc/wsl.conf
sudo chmod 644 /etc/wsl.conf
echo "wsl.conf instalado. Reiniciá WSL con:  wsl --shutdown"
