#!/usr/bin/env bash
# Restaura un dump (pg_dump -Fc) de Postgres en un volumen nombrado.
# Uso: pg-restore.sh <volumen> <base> <dump>
# Ej. : pg-restore.sh crm_devcontainer_crm-postgres-data crm_development ~/backups/crm.dump
#
# Nota: inicializa el cluster con auth 'trust' (sin password). El password del
# rol no viaja en un dump de una sola base; reestablecelo luego con:
#   ALTER USER postgres PASSWORD '...';
set -euo pipefail

vol="${1:?volumen}"; db="${2:?base}"; dump="${3:?dump}"
name="pg-restore-$$"

cleanup() { docker rm -f "$name" >/dev/null 2>&1 || true; }
trap cleanup EXIT

docker volume create "$vol" >/dev/null
docker run --rm -d --name "$name" \
  -v "$vol:/var/lib/postgresql/data" \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_DB=postgres \
  -e POSTGRES_HOST_AUTH_METHOD=trust \
  postgres:17 >/dev/null

for _ in $(seq 1 40); do
  docker exec "$name" psql -U postgres -tAc "SELECT 1" >/dev/null 2>&1 && break
  sleep 1
done

exists=$(docker exec "$name" psql -U postgres -tAc "SELECT 1 FROM pg_database WHERE datname='$db'" 2>/dev/null)
if [ "$exists" != "1" ]; then
  docker exec "$name" createdb -U postgres "$db"
fi

docker cp "$dump" "$name:/tmp/db.dump"
docker exec "$name" pg_restore -U postgres --no-owner -d "$db" /tmp/db.dump

tables=$(docker exec "$name" psql -U postgres -tAc "SELECT count(*) FROM pg_tables WHERE schemaname='public'" -d "$db")
echo "restaurado '$db' en '$vol': $tables tablas"
