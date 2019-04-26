#!/bin/bash
set -e

echo "Running feature test"
docker-compose -f test.yml run --rm test_selenium /usr/local/bin/behave /deploy/features/