#!/usr/bin/env bash
#
# Run this script when the initial database build fails. See the troubleshooting section of the
# readme for more information
#

export PGPASSWORD=ckan

# Drop the current db
psql -h db -U postgres -d postgres -c "drop database ckan_default"

# Create the db again
psql -h db -U postgres -d postgres -c "create database ckan_default with owner='ckan_default' encoding='utf-8' template='template_postgis'"

# Initialise the database
ckan-paster --plugin=ckan db init

# Initialise the reports
ckan-paster --plugin=ckanext-report report initdb

# Initialise the harvesting database
ckan-paster --plugin=ckanext-harvest harvester initdb

# Initialise the spatial database
ckan-paster --plugin=ckanext-spatial spatial initdb 4326

# Initialise the analytics db
ckan-paster --plugin=ckanext-ga-report initdb

# Import publishers & their harvesters
ckan-paster --plugin=ckanext-defra import_publishers
