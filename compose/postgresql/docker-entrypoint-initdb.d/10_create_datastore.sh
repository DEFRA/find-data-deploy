#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    CREATE ROLE $DATASTORE_READONLY_USER NOSUPERUSER NOCREATEDB NOCREATEROLE LOGIN PASSWORD '$DATASTORE_READONLY_PASSWORD';
    CREATE DATABASE $DATASTORE_DB_NAME OWNER $POSTGRES_USER ENCODING 'utf-8';
    GRANT ALL PRIVILEGES ON DATABASE $DATASTORE_DB_NAME TO $POSTGRES_USER;
EOSQL

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    CREATE DATABASE xloader_jobs OWNER $POSTGRES_USER ENCODING 'utf-8';
    GRANT ALL PRIVILEGES ON DATABASE xloader_jobs TO $POSTGRES_USER;
EOSQL

psql -v ON_ERROR_STOP=1 --username "$CKAN_DB_USER" -d $DATASTORE_DB_NAME <<-EOSQL
    CREATE OR REPLACE FUNCTION populate_full_text_trigger() RETURNS trigger
    AS \$body\$
        BEGIN
            IF NEW._full_text IS NOT NULL THEN
                RETURN NEW;
            END IF;
            NEW._full_text := (
                SELECT to_tsvector(string_agg(value, ' '))
                FROM json_each_text(row_to_json(NEW.*))
                WHERE key NOT LIKE '\_%');
            RETURN NEW;
        END;
    \$body\$ LANGUAGE plpgsql;
    ALTER FUNCTION populate_full_text_trigger() OWNER TO $CKAN_DB_USER;
EOSQL
