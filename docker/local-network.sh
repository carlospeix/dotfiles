#!/usr/bin/env bash
# Crea la red externa compartida por varios devcontainers
# (website17, eventer, cenped...). Idempotente.
set -euo pipefail

if docker network create local-kleer-network 2>/dev/null; then
  echo "local-network creada"
else
  echo "local-network ya existe"
fi
docker network inspect local-kleer-network --format 'driver={{.Driver}} scope={{.Scope}}'
