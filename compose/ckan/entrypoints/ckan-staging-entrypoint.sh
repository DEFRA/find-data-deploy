#!/bin/sh
set -e

# URL for the primary database, in the format expected by sqlalchemy (required
# unless linked to a container called 'db')
: ${CKAN_SQLALCHEMY_URL:=}
# URL for solr (required unless linked to a container called 'solr')
: ${CKAN_SOLR_URL:=}
# URL for redis (required unless linked to a container called 'redis')
: ${CKAN_REDIS_URL:=}

CONFIG="/etc/ckan/staging.ini"

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
  export PGPASSWORD=ckan
}

write_config () {
  ckan-paster make-config --no-interactive ckan "$CONFIG"
}

# If we don't already have a config file, bootstrap
if [ ! -e "$CONFIG" ]; then
  write_config
fi

# Get or create CKAN_SQLALCHEMY_URL
if [ -z "$CKAN_SQLALCHEMY_URL" ]; then
  abort "ERROR: no CKAN_SQLALCHEMY_URL specified in docker-compose.yml"
fi

if [ -z "$CKAN_SOLR_URL" ]; then
    abort "ERROR: no CKAN_SOLR_URL specified in docker-compose.yml"
fi

if [ -z "$CKAN_REDIS_URL" ]; then
    abort "ERROR: no CKAN_REDIS_URL specified in docker-compose.yml"
fi

set_environment

if [ ! -f /tmp/.initialized ]; then

    # Initialise the database
    ckan-paster --plugin=ckan db init -c /etc/ckan/staging.ini

    # Initialise the reports
    ckan-paster --plugin=ckanext-report report initdb

    # Initialise the harvesting database
    ckan-paster --plugin=ckanext-harvest harvester initdb -c /etc/ckan/staging.ini

    # Set datastore permissions
    ckan-paster --plugin=ckan datastore set-permissions -c /etc/ckan/staging.ini | psql -h db_staging -d datastore -U ckan_default

    # Change postgis permissions (1/2)
    psql -h db_staging -d ckan_default -U ckan_default -c 'ALTER VIEW geometry_columns OWNER TO ckan_default;'

    # Change postgis permissions (2/2)
    psql -h db_staging -d ckan_default -U ckan_default -c 'ALTER TABLE spatial_ref_sys OWNER TO ckan_default;'

    # Initialise the spatial database
    ckan-paster --plugin=ckanext-spatial spatial initdb 4326 -c /etc/ckan/staging.ini

    # Initialise the analytics db
    ckan-paster --plugin=ckanext-ga-report initdb -c /etc/ckan/staging.ini

    touch /tmp/.initialized
fi

/usr/lib/ckan/venv/bin/uwsgi --pcre-jit --ini /uwsgi.conf --plugins http,python,gevent --socket /tmp/uwsgi.sock --uid 900 --gid 900 --http :5000 --master --enable-threads --paste config:/etc/ckan/staging.ini --lazy-apps --gevent 2000 -p 2 -L
