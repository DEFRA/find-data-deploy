#!/usr/bin/env bash

psql -U postgres -c "CREATE EXTENSION postgis;"
psql -U postgres -c "CREATE EXTENSION postgis_topology;"
psql -U postgres -c "CREATE USER $CKAN_DB_USER WITH PASSWORD '$POSTGRES_PASSWORD';"
psql -U postgres -c "CREATE DATABASE $CKAN_DB_NAME WITH OWNER '$CKAN_DB_USER';"

psql -U postgres -d $CKAN_DB_NAME -f /usr/local/share/postgresql/contrib/postgis-2.5/postgis.sql
psql -U postgres -d $CKAN_DB_NAME -f /usr/local/share/postgresql/contrib/postgis-2.5/spatial_ref_sys.sql
psql -U postgres -d $CKAN_DB_NAME -c "ALTER VIEW geometry_columns OWNER TO $CKAN_DB_USER;"
psql -U postgres -d $CKAN_DB_NAME -c "ALTER TABLE spatial_ref_sys OWNER TO $CKAN_DB_USER;"

