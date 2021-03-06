#!/bin/bash
set -e

# URL for the primary database, in the format expected by sqlalchemy (required
# unless linked to a container called 'db')
: ${CKAN_SQLALCHEMY_URL:=}
# URL for solr (required unless linked to a container called 'solr')
: ${CKAN_SOLR_URL:=}
# URL for redis (required unless linked to a container called 'redis')
: ${CKAN_REDIS_URL:=}

abort () {
  echo "$@" >&2
  exit 1
}

set_environment () {
  export CKAN_SITE_ID=${CKAN_SITE_ID}
  export CKAN_SITE_URL=${CKAN_SITE_URL}
  export CKAN_SQLALCHEMY_URL=${CKAN_SQLALCHEMY_URL}
  export CKAN_SOLR_URL=${CKAN_SOLR_URL}
  export CKAN_REDIS_URL=${CKAN_REDIS_URL}
  export CKAN_STORAGE_PATH=/var/lib/ckan
  export CKAN_DATASTORE_WRITE_URL=${CKAN_DATASTORE_WRITE_URL}
  export CKAN_DATASTORE_READ_URL=${CKAN_DATASTORE_READ_URL}
  export CKAN_SMTP_SERVER=${CKAN_SMTP_SERVER}
  export CKAN_SMTP_STARTTLS=${CKAN_SMTP_STARTTLS}
  export CKAN_SMTP_USER=${CKAN_SMTP_USER}
  export CKAN_SMTP_PASSWORD=${CKAN_SMTP_PASSWORD}
  export CKAN_SMTP_MAIL_FROM=${CKAN_SMTP_MAIL_FROM}
  export CKAN_MAX_UPLOAD_SIZE_MB=${CKAN_MAX_UPLOAD_SIZE_MB}
  export PGPASSWORD=${POSTGRES_PASSWORD}
  export POSTGRES_USER=${CKAN_DB_USER}
  export CKAN_DB_NAME=${CKAN_DB_NAME}
  export CKAN_INI=${CKAN_INI}
  export DB_HOST=${DB_HOST}
}

write_config () {
  ckan-paster make-config --no-interactive ckan "$CKAN_INI"
}

# If we don't already have a config file, bootstrap
if [ ! -e "$CKAN_INI" ]; then
  write_config
fi

set_environment

function postgres_ready(){
/usr/lib/ckan/venv/bin/python << END
import sys
import psycopg2
try:
    conn = psycopg2.connect(dbname="$CKAN_DB_NAME", user="$CKAN_DB_USER", password="$POSTGRES_PASSWORD", host="$DB_HOST")
except psycopg2.OperationalError:
    sys.exit(-1)
sys.exit(0)
END
}

until postgres_ready; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 1
done

>&2 echo "Postgres is up - continuing..."

if [[ -z "${TRAVIS}" ]]; then

    # Create the db tables
    echo "Init ckan db"
    ckan-paster --plugin=ckan db init -c ${CKAN_INI} || true

    echo "Init reports db"
    ckan-paster --plugin=ckanext-report report initdb -c ${CKAN_INI} || true

    # Set permissions for test databases
    echo "Set permissions"
    ckan-paster --plugin=ckan datastore set-permissions -c ${CKAN_INI} | psql -U ckan_default -h test_db -d datastore

    # Initialise the spatial database
    echo "Init spatial db"
    ckan-paster --plugin=ckanext-spatial spatial initdb 4326 -c ${CKAN_INI} || true

    echo "Init harvester"
    ckan-paster --plugin=ckanext-harvest harvester initdb -c ${CKAN_INI} || true

    echo "Init analytics"
    ckan-paster --plugin=ckanext-ga-report initdb -c ${CKAN_INI} || true

    # Import publishers
    echo "Import publishers"
    ckan-paster --plugin=ckanext-defra import_publishers -c ${CKAN_INI} || true
fi

exec "$@"
