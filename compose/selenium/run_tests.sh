#!/usr/bin/env bash

echo "Installing test requirements"
pip install -r /deploy/requirements/test.txt

echo "Running tests"
/usr/local/bin/behave /deploy/features/
