#!/bin/bash
set -e

echo "This is travis-build.bash..."

echo "Installing test requirements"
pip install -r requirements/test.txt

docker-compose -f test.yml up -d

echo "travis-build.bash is done."
