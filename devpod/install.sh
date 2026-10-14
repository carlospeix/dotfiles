#!/usr/bin/env bash
# Instala los dotfiles en un container de DevPod.
# DevPod lo ejecuta al crear el workspace (DOTFILES_SCRIPT=devpod/install.sh).
# No usa .gitconfig ni .bashrc completos: rompen la firma y las credenciales
# que configura DevPod.
set -euo pipefail

dotfiles="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Aliases y vim
ln -sf "$dotfiles/.aliases" ~/.aliases
ln -sf "$dotfiles/.vimrc" ~/.vimrc
line='[ -f "${HOME}/.aliases" ] && source "${HOME}/.aliases"'
grep -qxF "$line" ~/.bashrc 2>/dev/null || echo "$line" >>~/.bashrc

# Git (lo portable; user, email y firma los configura DevPod)
git config --global core.autocrlf input
git config --global init.defaultBranch main
git config --global commit.gpgsign true
git config --global tag.gpgsign true
if command -v vim >/dev/null; then git config --global core.editor vim; fi

# Workaround bug DevPod: configura git con `su <user> -c` desde /root (700)
# y git falla con "error reading '/root/.git'". Ver: https://github.com/skevetter/devpod/issues/783
sudo -n chmod o+x /root 2>/dev/null || echo "Aviso: no se pudo chmod /root (sin sudo)"

echo "dotfiles DevPod instalados."
