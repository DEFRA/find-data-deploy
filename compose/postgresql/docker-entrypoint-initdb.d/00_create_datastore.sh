#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    CREATE ROLE datastore_ro NOSUPERUSER NOCREATEDB NOCREATEROLE LOGIN PASSWORD '$DS_RO_PASS';
    CREATE DATABASE datastore OWNER ckan_default ENCODING 'utf-8';
    GRANT ALL PRIVILEGES ON DATABASE datastore TO ckan_default;
EOSQL

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    CREATE_DATABASE xloader_jobs OWNER ckan_default ENCODING 'utf-8';
    GRANT ALL PRIVILEGES ON DATABASE xloader_jobs TO ckan_default;
EOSQL
