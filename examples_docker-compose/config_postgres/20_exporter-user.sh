#!/bin/sh
set -e

: "${POSTGRES_USER:="postgres"}"

: "${EXPORTER_USER:="postgres_exporter"}"
: "${EXPORTER_PASSWORD:="Exp0rt3r!"}"

# PostgreSQL versions >= 10  <https://github.com/prometheus-community/postgres_exporter#running-as-non-superuser>

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -tc \
"SELECT 1 FROM pg_catalog.pg_user WHERE usename = '${EXPORTER_USER}'" \
| grep -q 1 \
|| psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<EOSQL
---CREATE USER ${EXPORTER_USER};
---ALTER USER ${EXPORTER_USER} WITH PASSWORD '${EXPORTER_PASSWORD}';
CREATE ROLE ${EXPORTER_USER} WITH LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE INHERIT NOREPLICATION CONNECTION LIMIT -1 PASSWORD '${EXPORTER_PASSWORD}';
ALTER USER ${EXPORTER_USER} SET SEARCH_PATH TO ${EXPORTER_USER},pg_catalog;
GRANT CONNECT ON DATABASE postgres TO ${EXPORTER_USER};
GRANT pg_monitor to ${EXPORTER_USER};
EOSQL

#psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -c "SELECT * FROM pg_catalog.pg_user;"
