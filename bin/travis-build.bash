#!/bin/bash
set -e

echo "This is travis-build.bash..."

echo "Installing test requirements"
pip install -r requirements/test.txt

echo "Building containers"
docker-compose -f test.yml build

echo "Creating test data"
docker-compose -f test.yml run --rm test_selenium /usr/lib/ckan/venv/bin/ckan-paster --plugin=ckan create-test-data

echo "Generating reports"
docker-compose -f test.yml run --rm test_selenium /usr/lib/ckan/venv/bin/paster --plugin=ckanext-defrareports check_broken_resources

echo "travis-build.bash is done."
