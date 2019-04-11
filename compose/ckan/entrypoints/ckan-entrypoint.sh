#!/bin/sh
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
}

write_config () {
  ckan-paster make-config --no-interactive ckan "$CKAN_INI"
}

# If we don't already have a config file, bootstrap
if [ ! -e "$CKAN_INI" ]; then
  write_config
fi

set_environment

if [ ! -f /tmp/.initialized ]; then

    # Initialise the database
    ckan-paster --plugin=ckan db init -c ${CKAN_INI}

    # Initialise the reports
    ckan-paster --plugin=ckanext-report report initdb

    # Initialise the harvesting database
    ckan-paster --plugin=ckanext-harvest harvester initdb -c ${CKAN_INI}

    # Set datastore permissions
    ckan-paster --plugin=ckan datastore set-permissions -c ${CKAN_INI} | psql -h db -d datastore -U ${POSTGRES_USER}

    # Change postgis permissions (1/2)
    psql -h db -d ${CKAN_DB_NAME} -U ${POSTGRES_USER} -c 'ALTER VIEW geometry_columns OWNER TO ckan_default;'

    # Change postgis permissions (2/2)
    psql -h db -d ${CKAN_DB_NAME} -U ${POSTGRES_USER} -c 'ALTER TABLE spatial_ref_sys OWNER TO ckan_default;'

    # Initialise the spatial database
    ckan-paster --plugin=ckanext-spatial spatial initdb 4326 -c ${CKAN_INI}

    # Initialise the analytics db
    ckan-paster --plugin=ckanext-ga-report initdb -c ${CKAN_INI}

    # Import publishers & their harvesters
    ckan-paster --plugin=ckanext-defra import_publishers -c ${CKAN_INI}

    touch /tmp/.initialized
fi

exec "$@"
