# Docker nativo en Debian (migración desde Docker Desktop)

Procedimiento para dejar de usar Docker Desktop (Windows) y correr Docker Engine
nativo dentro de Debian (WSL2), con systemd.

## Por qué

Docker Desktop integra su engine con WSL mediante un proxy (`cli-tools`,
`backend.sock`) que se rompe con frecuencia (HTTP 500 / symlink caído). Correr
`dockerd` nativo en la distro elimina esa capa.

## 1. Desconectar Docker Desktop

En Debian, quitar los artefactos de la integración:

```sh
sudo rm -f /usr/bin/docker            # symlink a cli-tools de Docker Desktop
docker context use default
docker context rm desktop-linux
# ~/.docker/config.json: quitar "credsStore": "desktop.exe" (ver docker/config.json)
```

En la UI de Docker Desktop: Settings > Resources > WSL Integration, desmarcar
Debian, Apply y Quit. (Opcional: desinstalar Docker Desktop desde Windows.)

## 2. Activar systemd

```sh
cd ~/dotfiles && ./wsl/apply.sh
wsl --shutdown
# verificar:
ps -p 1 -o comm=        # debe imprimir "systemd"
systemctl is-system-running   # "running"
```

## 3. Instalar Docker Engine

```sh
cd ~/dotfiles && ./docker/install-docker-debian.sh
```

El grupo `docker` (GID 1001) ya incluye al usuario; el socket queda accesible
sin sudo.

## 4. Recursos compartidos

```sh
./docker/local-network.sh
```

## 5. Backups / restauración de Postgres (crm, fugazzeta)

Los devcontainers de `crm` y `fugazzeta` usan PostgreSQL (`postgres:17`) con
volúmenes nombrados. Para migrar sus bases sin copiar el volumen crudo:

Dump (antes de abandonar Docker Desktop):

```sh
docker run --rm -d --name pgdump \
  -v crm_devcontainer_crm-postgres-data:/var/lib/postgresql/data \
  -e POSTGRES_USER=postgres -e POSTGRES_HOST_AUTH_METHOD=trust postgres:17
docker exec pgdump pg_dump -U postgres -d crm_development -Fc -f /tmp/crm.dump
docker cp pgdump:/tmp/crm.dump ~/backups/crm_development.dump
docker rm -f pgdump
```

Restauración (en el engine nativo):

```sh
./docker/pg-restore.sh crm_devcontainer_crm-postgres-data crm_development ~/backups/crm_development.dump
./docker/pg-restore.sh fugazzeta_devcontainer_fugazzeta-postgres fugazzeta_dev ~/backups/fugazzeta_dev.dump
```

## 6. Contraseña de Postgres

El dump de una sola base no incluye el password del rol. La restauración usa
`trust`. Para volver a exigir contraseña:

```sql
ALTER USER postgres PASSWORD 'la-misma-de-tu-env';
```

Los valores están en `crm/.env` (`POSTGRES_PASSWORD`) y `fugazzeta.env`
(`PGDATABASE_PSW`).
