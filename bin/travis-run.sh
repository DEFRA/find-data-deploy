#!/bin/bash
set -e

echo "Bringing containers up"
docker-compose -f test.yml up -d

echo "Running feature tests"
docker-compose -f test.yml run --rm test_selenium /deploy/compose/selenium/run_tests.sh; echo $?
