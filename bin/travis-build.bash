#!/bin/bash
set -e

echo "This is travis-build.bash..."

echo "Installing test requirements"
pip install -r requirements/test.txt

echo "Installing the defra extension..."
cd ckanext-extensions
git clone https://github.com/DEFRA/ckanext-defra.git
cd ckanext-defra
python setup.py develop
pip install -r dev-requirements.txt
cd ../

echo "Installing the defrareports extension..."
git clone https://github.com/DEFRA/ckanext-defrareports.git
cd ckanext-defrareports
python setup.py develop
pip install -r requirements.txt
pip install -r dev-requirements.txt
pip install -r test-requirements.txt
cd ../../

docker-compose -f test.yml up -d

echo "travis-build.bash is done."
