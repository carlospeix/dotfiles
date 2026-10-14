#!/usr/bin/env bash
# Instala sshd para SSH desde Windows (herdr): 127.0.0.1:22, solo clave.
# Requiere sudo.
set -euo pipefail

src="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/sshd-local.conf"

sudo apt-get install -y openssh-server
sudo cp "$src" /etc/ssh/sshd_config.d/local.conf
sudo chmod 644 /etc/ssh/sshd_config.d/local.conf
sudo sshd -t
sudo systemctl enable ssh
sudo systemctl restart ssh
echo "sshd escuchando en 127.0.0.1:22"
