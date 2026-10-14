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

## Dev Containers + Claude Code en WSL

El IDE (VS Code Dev Containers, `dev.containers.executeInWSL: true`) trabaja
dentro del container. Claude Code corre en WSL, edita el repo directamente y
ejecuta comandos en ese mismo container con `dcx`.

### `dcx` (`bin/dcx`, link en `~/.local/bin`)

```sh
dcx bin/rails test     # ejecuta en el container del repo actual, como remoteUser
dcx --start            # arranca el container existente (VS Code lo detiene al cerrar)
dcx --stop             # detiene el container
```

- Encuentra el container por el label `devcontainer.config_file`. Con
  `executeInWSL`, VS Code pone `devcontainer.local_folder` como ruta UNC
  (`\wsl.localhost\...`). Por eso `devcontainer exec/up --workspace-folder`
  desde WSL **no** lo encuentra, y `up` crearía un segundo container.
- Usa `devcontainer exec --container-id`, que respeta `remoteUser`,
  `containerEnv` y el entorno de login (PATH de nvm, gems). El cwd es el
  `workspaceFolder`. Propaga el exit code y stdin.
- Nunca crea containers. Exit codes: 2 = no hay devcontainer.json,
  3 = container detenido o inexistente, 4 = hay más de uno.

Claude: la regla está en `~/.claude/CLAUDE.md` (compartido con Windows) y el
permiso `Bash(dcx:*)` en `~/.claude/settings.json`. Git siempre corre en WSL.

### Firma de commits

- Desde WSL (Claude): git + agente de WSL (`~/.ssh/agent.sock`).
- Desde VS Code (terminal o UI dentro del container): VS Code reenvía el
  agente de WSL (`/tmp/vscode-ssh-auth-*.sock`) y monta `~/.gitconfig`
  readonly. En sesiones `dcx` no hay agente, así que no firman.

### Puerto 3000 sin IDE

En `devcontainer.json`:

```jsonc
"containerEnv": { "BINDING": "0.0.0.0" },     // Rails escucha fuera de loopback del container
"appPort": ["127.0.0.1:3000:3000"]            // Docker publica solo en loopback del host
```

`localhost:3000` funciona desde Windows (localhost forwarding de WSL) con o
sin IDE. No usar `forwardPorts` junto con esto: VS Code se iría al 3001. En un
VPS, el `127.0.0.1:` es lo que evita exponer el puerto (Docker saltea ufw);
se accede con `ssh -L 3000:localhost:3000`.

### Zed

No sirve para esto: los Dev Containers de Zed solo funcionan con proyectos
locales, y un proyecto WSL abierto desde Zed para Windows es remoto ("Cannot
open Dev Container from remote project"). La alternativa sería Zed Linux en
WSL vía WSLg (no probada).

## SSH desde Windows a WSL

Para herdr (Windows → Debian).

### En WSL

```sh
~/dotfiles/wsl/apply-sshd.sh   # sshd en 127.0.0.1:22, solo clave
```

La clave pública de Windows tiene que estar en `~/.ssh/authorized_keys`.

Todas las distros WSL2 comparten la red: un solo sshd puede usar el 22. En
Ubuntu está deshabilitado (`systemctl disable --now ssh.socket ssh`).

### En Windows

`~/.ssh/config` (`127.0.0.1` y no `localhost`, para evitar la demora por IPv6):

```
Host wsl-debian
  HostName 127.0.0.1
  User carlos
  Port 22
  IdentityFile ~/.ssh/id_ed25519_wsl
  IdentitiesOnly yes
```

Si cambia el sshd que atiende `127.0.0.1:22`: `ssh-keygen -R 127.0.0.1`.

## DevPod (para VPS, futuro)

Descartado para uso local: no aporta sobre Dev Containers + `dcx`.

En Windows:

- Git for Windows: VS Code usa su `ssh.exe`, porque el OpenSSH de Windows se
  cuelga con el `ProxyCommand` de DevPod.
- DevPod: `winget install Skvetter.DevPod` (agregar `C:\Program Files\DevPod`
  al PATH si no está).
- VS Code (`settings.json`):

  ```json
  "remote.SSH.path": "C:\Program Files\Git\usr\bin\ssh.exe"
  ```

- Provider (un `Host` en `~/.ssh/config`) y dotfiles:

  ```powershell
  devpod provider add ssh --name <vps> -o HOST=<host-ssh>
  devpod context set-options -o DOTFILES_URL=https://github.com/carlospeix/dotfiles -o DOTFILES_SCRIPT=devpod/install.sh
  ```

  Las opciones de dotfiles ya están configuradas en el contexto `default`.

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
