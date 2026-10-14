#!/usr/bin/env bash
# Instala los dotfiles en WSL: symlinks a este repo y a configs de Windows.
# Idempotente: si el destino existe y no es el link esperado, lo respalda
# como <archivo>.bak.<fecha>. No usa sudo (ver wsl/apply.sh, wsl/apply-sshd.sh).
set -euo pipefail

dotfiles="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
winhome="${WINHOME:-/mnt/c/Users/carlos}"

# link <origen> <destino>
link() {
  local src="$1" dst="$2"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then return; fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    mv "$dst" "$dst.bak.$(date +%Y%m%d%H%M%S)"
    echo "backup: $dst"
  fi
  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst"
  echo "link: $dst -> $src"
}

# Dotfiles del repo
for f in .aliases .bashrc .gitconfig .profile .vimrc .npmrc .config/git/ignore; do
  link "$dotfiles/$f" "$HOME/$f"
done

# Configs compartidas con Windows
link "$winhome/.claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
link "$winhome/.config/opencode/opencode.jsonc" "$HOME/.config/opencode/opencode.jsonc"

# Secretos locales (no versionados)
[ -f ~/.bashrc_private ] || touch ~/.bashrc_private
chmod 600 ~/.bashrc_private

echo "dotfiles WSL instalados."
