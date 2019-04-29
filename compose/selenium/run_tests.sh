#!/usr/bin/env bash

echo "Installing test requirements"
pip install -r /deploy/requirements/test.txt

#function postgres_ready(){
#python << END
#import sys
#import psycopg2
#try:
#    conn = psycopg2.connect(dbname="ckan_test", user="ckan_default", password="ckan", host="test_db")
#except psycopg2.OperationalError:
#    sys.exit(-1)
#except KeyboardInterrupt:
#    sys,exit(-1)
#sys.exit(0)
#END
#}
#
#until postgres_ready; do
#  >&2 echo "Postgres is unavailable - sleeping"
#  sleep 1
#done
#
#>&2 echo "Postgres is up - continuing..."

/usr/local/bin/behave /deploy/features/
