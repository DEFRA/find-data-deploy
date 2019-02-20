#!/bin/bash
export PGPASSWORD=ckan
# Do not pick up datastore db details from the environment
unset CKAN_DATASTORE_READ_URL CKAN_DATASTORE_WRITE_URL
# Create test databases
psql -h db -p 5432 -U ckan_default -c "CREATE DATABASE ckan_test OWNER=ckan_default encoding='utf-8';"
psql -h db -p 5432 -U ckan_default -c "CREATE DATABASE datastore_test OWNER=ckan_default encoding='utf-8';"
# Set permissions for test databases
/usr/local/bin/ckan-paster --plugin=ckan datastore set-permissions -c /etc/ckan/test.ini | psql -U ckan_default -h db -p 5432
