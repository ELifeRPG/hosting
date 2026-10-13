#!/usr/bin/env bash
set -euo pipefail

create() {
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname postgres \
    -v name="$1" -v password="$2" <<'SQL'
CREATE ROLE :"name" LOGIN PASSWORD :'password';
CREATE DATABASE :"name" OWNER :"name";
REVOKE ALL ON DATABASE :"name" FROM PUBLIC;
SQL
}

create keycloak "$KEYCLOAK_DB_PASSWORD"
create backend "$BACKEND_DB_PASSWORD"
create npc "$NPC_DB_PASSWORD"
