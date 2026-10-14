# dotfiles

Basado en los dotfiles de [Nick Janetakis](https://github.com/nickjj/dotfiles).

Entorno de desarrollo en Windows 11 con WSL2 (Debian), Docker Engine nativo
(sin Docker Desktop) y DevPod.

## Requisitos

- Windows 11 con WSL2.
- Debian en WSL2. Los scripts de `docker/` usan el repositorio de Docker para Debian.

## Instalación en WSL

### 1. Paquetes base

```sh
sudo apt-get update
sudo apt-get install -y \
  ca-certificates curl wget git git-lfs gh gpg gnupg \
  build-essential vim htop rsync zip unzip jq fzf ripgrep fd-find \
  pwgen xclip
gh auth login
```

Opcionales según el proyecto:

- Ruby: `ruby-full ruby-dev`
- Python: `python3 python3-dev python3-pip python3-venv`
- Node.js: desde [NodeSource](https://github.com/nodesource/distributions)
- .NET: SDK en `~/.dotnet` (`DOTNET_ROOT` ya está en `.bashrc`)

### 2. Clonar el repo

```sh
git clone https://github.com/carlospeix/dotfiles ~/dotfiles
```

### 3. Configuración de WSL

Activa systemd y el usuario por defecto (`/etc/wsl.conf`):

```sh
~/dotfiles/wsl/apply.sh
```

Copiar `.wslconfig` a Windows (revisar antes los valores, por ejemplo la memoria):

```sh
cp ~/dotfiles/c/Users/Carlos/.wslconfig /mnt/c/Users/carlos/.wslconfig
```

Reiniciar WSL desde Windows con `wsl --shutdown`.

### 4. Docker Engine

```sh
~/dotfiles/docker/install-docker-debian.sh
sudo usermod -aG docker "$USER"   # requiere cerrar y abrir sesión
```

- `docker/local-network.sh`: red externa compartida.
- `docker/pg-restore.sh`: restaura dumps de Postgres en volúmenes nombrados.
- `docs/docker-migration.md`: procedimiento completo de migración.

### 5. Dotfiles

```sh
~/dotfiles/wsl/install.sh
```

Crea symlinks a los dotfiles del repo y a configs compartidas con Windows
(`CLAUDE.md`, opencode). Es idempotente: si un destino existe, lo respalda
como `<archivo>.bak.<fecha>`.

Los secretos van en `~/.bashrc_private` (no versionado, permisos 600).

Firma de commits: `~/.ssh/allowed_signers` se mantiene a mano, con una línea
por clave pública de firma (WSL y Windows):

```
carlos.peix@gmail.com namespaces="git" ssh-ed25519 AAAA...
```

### 6. Herramientas globales

npm (instala en `~/.npm-global`, configurado en `.npmrc`):

```sh
npm install -g @anthropic-ai/claude-code opencode-ai @fission-ai/openspec \
  @devcontainers/cli ccstatusline
```

`herdr`: binario en `~/.local/bin`.

`wsl/fix-interop.sh`: restaura la interop con Windows si falla la ejecución
de `.exe` ("Exec format error").

## DevPod

Provider SSH desde Windows hacia este Debian.

### En WSL

```sh
~/dotfiles/wsl/apply-sshd.sh   # sshd en 127.0.0.1:2222, solo clave
```

La clave pública de Windows tiene que estar en `~/.ssh/authorized_keys`.

### En Windows

- Git for Windows: VS Code usa su `ssh.exe`, porque el OpenSSH de Windows se
  cuelga con el `ProxyCommand` de DevPod.
- DevPod: `winget install Skvetter.DevPod` (agregar `C:\Program Files\DevPod`
  al PATH si no está).
- `~/.ssh/config` (`127.0.0.1` y no `localhost`, para evitar la demora por IPv6):

  ```
  Host wsl-debian
    HostName 127.0.0.1
    User carlos
    Port 2222
    IdentityFile ~/.ssh/id_ed25519_wsl
    IdentitiesOnly yes
  ```

- VS Code (`settings.json`):

  ```json
  "remote.SSH.path": "C:\Program Files\Git\usr\bin\ssh.exe"
  ```

- Provider y dotfiles:

  ```powershell
  devpod provider add ssh --name wsl -o HOST=wsl-debian -o PORT=2222
  devpod context set-options -o DOTFILES_URL=https://github.com/carlospeix/dotfiles -o DOTFILES_SCRIPT=devpod/install.sh
  ```

`devpod/install.sh` corre dentro de cada container: aliases, vim, config
portable de git, firma automática y el workaround del bug de `/root`.

Uso:

```powershell
devpod up <repo-o-carpeta> --ide vscode
devpod list
devpod stop <nombre>
devpod delete <nombre>
```

## Windows Terminal

`c/Users/Carlos/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json`:
copiar a mano a la misma ruta en Windows.
