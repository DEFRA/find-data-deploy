#!/bin/bash
export PGPASSWORD=ckan

# Do not pick up datastore db details from the environment
unset CKAN_DATASTORE_READ_URL CKAN_DATASTORE_WRITE_URL

# Create test databases
psql -h db -p 5432 -U ckan_default -c "CREATE DATABASE ckan_test OWNER=ckan_default encoding='utf-8';"
psql -h db -p 5432 -U ckan_default -c "CREATE DATABASE datastore_test OWNER=ckan_default encoding='utf-8';"

# Set permissions for test databases
/usr/local/bin/ckan-paster --plugin=ckan datastore set-permissions -c /etc/ckan/test.ini | psql -U ckan_default -h db -p 5432

# Create the db tables
/usr/local/bin/ckan-paster --plugin=ckan db init -c "/etc/ckan/test.ini"
/usr/local/bin/ckan-paster --plugin=ckanext-report report initdb -c "/etc/ckan/test.ini"

# Change postgis permissions (1/2)
psql -h db -d ckan_test -U ckan_default -c 'ALTER VIEW geometry_columns OWNER TO ckan_default;'

# Change postgis permissions (2/2)
psql -h db -d ckan_test -U ckan_default -c 'ALTER TABLE spatial_ref_sys OWNER TO ckan_default;'

# Initialise the spatial database
/usr/local/bin/ckan-paster --plugin=ckanext-spatial spatial initdb 4326 -c /etc/ckan/test.ini
/usr/local/bin/ckan-paster --plugin=ckanext-harvest harvester initdb -c /etc/ckan/test.ini
