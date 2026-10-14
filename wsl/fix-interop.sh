#!/usr/bin/env bash
# Restaura la interop de Windows en WSL (error "Exec format error" al correr .exe).
# Uso: ~/dotfiles/wsl/fix-interop.sh
set -uo pipefail

ENTRY=/proc/sys/fs/binfmt_misc/WSLInterop

enabled() {
  [ -r "$ENTRY" ] && grep -q '^enabled$' "$ENTRY" 2>/dev/null
}

if enabled; then
  echo "interop OK: ya funciona"
  exit 0
fi

echo "interop rota. Re-registrando WSLInterop..."
if [ "$(id -u)" -eq 0 ]; then
  echo ':WSLInterop:M::MZ::/init:P' > /proc/sys/fs/binfmt_misc/register
else
  sudo sh -c 'echo ":WSLInterop:M::MZ::/init:P" > /proc/sys/fs/binfmt_misc/register'
fi

if enabled; then
  echo "interop restaurada"
else
  echo "No se pudo restaurar. Reiniciá WSL desde Windows con:  wsl --shutdown" >&2
  exit 1
fi
