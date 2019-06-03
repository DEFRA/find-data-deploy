### Defra - Find Data Service

**Status:** Development

[![Build Status](https://travis-ci.org/DEFRA/find-data-deploy.svg?branch=master)](https://travis-ci.org/DEFRA/find-data-deploy)

This repository contains the development and deployment config for Defra's Find Data Project.

The Find Data project is made up of two CKAN extensions, one golang service and the deploy repo which you are currently looking at.

* [find-data-deploy](https://github.com/DEFRA/find-data-deploy)
  * This repo. Contains docker config/build scripts/feature tests for the project.
* [ckanext-defra](https://github.com/DEFRA/ckanext-defra)
  * This is the main defra plugin. It holds the theme and any custom routes/logic for the project. 
* [ckanext-defrareports](https://github.com/DEFRA/ckanext-defrareports)
  * This repo contains custom reports built on top of the [ckanext-report](https://github.com/datagovuk/ckanext-report) and [ckanext-gareport](https://github.com/datagovuk/ckanext-ga-report) plugins.
* [find-data-location-lookup](https://github.com/DEFRA/find-data-location-lookup)
  * A prototype microservice to serve location data based on ordinance survey master map data.


#### Get up and running locally

1. Grab the repo
    ```
    git clone --recursive git@github.com:DEFRA/find-data-deploy.git
    cd find-data-deploy
    ```

2. Grab the location data
    * Download the OS Open Names CSV from the [Ordinance Survey Website](https://www.ordnancesurvey.co.uk/opendatadownload/products.html#OPNAME)
    * Make a temporary directory to hold the data `mkdir compose/location/data/`
    * Unzip the downloaded csv to compose/location/data/
    * cd to the data dir `cd compose/location/data/`
    * Unzip the file `unzip opname_csv_gb.zip`
    * Merge all data into a single file for the go app `cat DATA/* | grep populatedPlace > merged_results.csv`
    * cd back to the project root dir `cd ../../../`

3. Setup your dev env

    To allow for development on running containers you will need to create a virtual environment and install the extensions for development.
    * From the project root run `virtualenv ~/.venv`
    * `source ~/.venv/bin/activate`
    * `pip install -e ckan-extensions/ckanext-defra`
    * `pip install -e ckan-extensions/ckanext-defrareports`
    * Alias ckan to localhost
        * Add `127.0.1.1      ckan` to `/etc/hosts` 
    
4. Get it running
    * From the project root, build the containers `docker-compose -f development.yml build`
    * Then initialise the database `docker-compose -f development.yml run --rm cron /rebuild-dev-db.sh`
    * Bring the containers up `docker-compose -f development.yml up`
    * Visit http://ckan
      * If ckan fails to start now please see the dev troubleshooting section

4. Admin User
    * Create a superuser account for yourself ``docker exec -it mdf-ckan /usr/local/bin/ckan-paster --plugin=ckan sysadmin add <YOUR USERNAME> email=<YOUR EMAIL> name=<YOUR USERNAME> -c /etc/ckan/development.ini``
    

### Dev Troubleshooting

There is an intermittent issue when first building the project where the database gets into a partially setup state.

If this is the case you may get errors like `...(psycopg2.ProgrammingError) column package.type does not exist` or `CKAN ERROR: column user.password does not exist at character...`

You can remedy this by performing the following steps:
 
  * Ensure all docker containers are stopped.
  * Run `docker-compose -f development.yml run --rm cron /rebuild-dev-db.sh`
  * Bring the containers up again `docker-compose -f development.yml up`


### Unit Tests

Run tests for both the defra and defrareports plugin. This will spin up a new dev environment and run the tests.
```.env
docker-compose -f test.yml run --rm test_ckan /usr/lib/ckan/venv/bin/nosetests --nologcapture --ckan --with-pylons=/usr/lib/ckan/venv/src/ckanext-defrareports/test.ini /usr/lib/ckan/venv/src/ckanext-defrareports/ckanext/defrareports/tests/ /usr/lib/ckan/venv/src/ckanext-defra/ckanext/defra/tests/
```

For quicker tests while developing you can drop into the ckan container and run the tests directly.
```.env

# Connect to the ckan container
docker-compose -f test.yml run --rm test_ckan /bin/bash

# Run defra tests
/usr/lib/ckan/venv/bin/nosetests --nologcapture --ckan --with-pylons=/usr/lib/ckan/venv/src/ckanext-defra/test.ini /usr/lib/ckan/venv/src/ckanext-defra/ckanext/defra/tests/

# Run defrareports tests
/usr/lib/ckan/venv/bin/nosetests --nologcapture --ckan --with-pylons=/usr/lib/ckan/venv/src/ckanext-defrareports/test.ini /usr/lib/ckan/venv/src/ckanext-defrareports/ckanext/defrareports/tests/
```

### Feature Testing
We use behave and selenium for feature testing. Before getting started you will need to ensure you have an admin user

```
docker exec -it mdf-ckan ckan-paster --plugin=ckan sysadmin add admin --config=/etc/ckan/development.ini
> Email address: admin@finddata
> Password: correct horse battery staple
```

You will also need to install the test requirements
```
pip install -r requirements/test.txt
```

Now, from the project directory you can run the tests
```
behave
```

### Deploying to Azure

As the project is currently in alpha deployment is done ad-hoc by tunnelling to our Azure container service and pointing docker to it. We can then quickly push out updates from dev machines.

**Azure Setup**
Note: You will need to set up ssh keys and get them added to the container service on the Azure portal.


**Configure Google Analytics**

  * Generate the config by following the instructions on the [ckanext-ga-report github page](https://github.com/datagovuk/ckanext-ga-report#setup-google-analytics)
  * Copy the file downloaded to compose/ckan/config/analytics-auth.json


**CKAN CONFIG**

You will also need to update the production ckan config in `compose/ckan/config/`. 

Copy `production_example.ini` to `production.ini`.

Then update the following settings with your own values:

* `beaker.session.secret` - generate a new secret for this variable
* `app_instance_uuid` - follow the steps generate a new uuid
* `ckan.site_url` - Update to the domain of your azure service
* `ckan.site_title`
* `smtp.*`, `email_to` - these should match your mail server setup
* `ckan.defra.location_service_url` - set this to `<your domain>/location-service`

The following db settings have default values set but should be changed for security reasons when you go live:

* `sqlalchemy.url`
* `ckan.datastore.write_url`
* `ckan.datastore.read_url`

-----------

**To deploy:**

1. Set the Google Analytics environment variables in your shell

    `export GOOGLE_ANALYTICS_SITE_ID=???`
    
    `export GOOGLE_ANALYTICS_USERNAME=???`
    
    `export GOOGLE_ANALYTICS_PASSWORD=???`
2. Log in to sentry and retrieve the dsn for your project
3. Set the Sentry DSN environment variable 
    
    `export SENTRY_DSN=???`
4. Set the Sendgrid password environment variable
 
    `export SENDGRID_PASSWORD=???`
5. Create the tunnel 
    
    `ssh dockeruser@<YOUR AZURE LOAD BALANCER IP ADDRESS> -p 2200 -L 22375:127.0.0.1:2375`
6. Point docker to the remote service
 
    `export DOCKER_HOST=":22375"`
7. Bring the containers up 
    
    `docker-compose -f production.yml up -d`

-----------

**SSL Certs**

We currently use [Letsencrypt](https://letsencrypt.org/) as our certificate authority.

Certificates can be created and updated via the letsencrypt docker container. The container only runs as needed when a certificate need to be renewed. 

You can use the commands below with the azure deploy tunnel activated to manage certs. 


Create certificates
```
docker-compose -f production.yml run --rm letsencrypt letsencrypt certonly --webroot --email <your email address> --agree-tos -w /var/www/letsencrypt -d <YOUR DOMAIN>
```

Renew certificates
```
docker-compose run --rm letsencrypt letsencrypt renew
```

