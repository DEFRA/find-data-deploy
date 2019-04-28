#!/bin/bash
set -e

echo "This is travis-build.bash..."

echo "Installing test requirements"
pip install -r requirements/test.txt

echo "Building containers"
docker-compose -f test.yml build

#echo "Bringing containers up"
#docker-compose -f test.yml up -d
#
#echo "Creating test data"
#docker-compose -f test.yml run --rm test_ckan /usr/lib/ckan/venv/bin/paster --plugin=ckan create-test-data
#
#echo "Generating reports"
#docker-compose -f test.yml run --rm test_ckan /usr/lib/ckan/venv/bin/paster --plugin=ckanext-report report generate -c /etc/ckan/test.ini
#
#echo "travis-build.bash is done."
