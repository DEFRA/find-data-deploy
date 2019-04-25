### Get up and running locally

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
    
3. Configure Google Analytics
    * Generate the config by following the instructions on the [ckanext-ga-report github page](https://github.com/datagovuk/ckanext-ga-report#setup-google-analytics)
    * Copy the file downloaded to compose/ckan/config/analytics-auth.json

4. Get it running
    * Alias ckan to localhost
        * Add `127.0.1.1      ckan` to `/etc/hosts` 
    * Bring the containers up `docker-compose -f development.yml up`
    * Visit http://ckan:5000
    * If ckan doesn't load after you first bring the containers up:
        * This is most likely caused by a race condition between the ckan container and the db.
        * Restarting the ckan container should sort it out `docker-compose -f development.yml up -d ckan`

5. User
    * Create a superuser account for yourself ``docker exec -it mdf-ckan /usr/local/bin/ckan-paster --plugin=ckan sysadmin add <YOUR USERNAME> email=<YOUR EMAIL> name=<YOUR USERNAME> -c /etc/ckan/development.ini``
    

### Deploying to Azure

Until we have set up an Azure container registry we deploy by creating an ssh tunnel to our Azure container service and pointing docker to it.

Note: You will need to set up ssh keys and get them added to the container service on the Azure portal.

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

### Unit Tests

Before you first run tests locally you will need to setup the test db
```.env
docker-compose -f test.yml run --rm test_ckan /init_tests.sh
```

Run tests for both the defra and defrareports plugin. This will spin up a new dev environment and run the tests.
```.env
docker-compose -f test.yml run --rm test_ckan /usr/lib/ckan/venv/bin/nosetests --nologcapture --ckan --with-pylons=/usr/lib/ckan/venv/src/ckanext-defrareports/test.ini /usr/lib/ckan/venv/src/ckanext-defrareports/ckanext/defrareports/tests/ /usr/lib/ckan/venv/src/ckanext-defra/ckanext/defra/tests/
```

For quicker tests while developing you can drop into the ckan container and run the tests directly.
```.env

# Connect to the ckan container
docker-compose -f test.yml run --rm test_ckan /bin/bash

# Run defra tests
/usr/lib/ckan/venv/bin/nosetests --nologcapture --ckan --with-pylons=/usr/lib/ckan/venv/src/ckanext-defrareports/test.ini /usr/lib/ckan/venv/src/ckanext-defra/ckanext/defra/tests/

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
