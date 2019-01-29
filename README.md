### Get up and running locally

1. Grab the repo
    ```
    git clone --recursive git@github.com:DEFRA/defradata-ckan-deploy.git
    cd defradata-ckan-deploy
    ```

2. Grab the location data
    * Download the OS Open Names CSV from the [Ordinance Survey Website](https://www.ordnancesurvey.co.uk/opendatadownload/products.html#OPNAME)
    * Make a temporary directory to hold the data `mkdir compose/location/data/`
    * Unzip the downloaded csv to compose/location/data/
    * cd to the data dir `cd compose/location/data/`
    * Unzip the file `unzip opname_csv_gb.zip`
    * Merge all data into a single file for the go app `cat DATA/* | grep populatedPlace > merged_results.csv`
    
3. Configure Google Analytics
    * cd to the root project dir `cd ../../../`
    * Visit the [Google Developers Service Accounts Page](https://console.developers.google.com/iam-admin/serviceaccounts?project=making-data-findable&folder&organizationId&angularJsUrl=%2Fprojectselector%2Fiam-admin%2Fserviceaccounts%3Fsupportedpurview%3Dproject%26project%3D%26folder%3D%26organizationId%3D&authuser=2&supportedpurview)
    * Click 'Create Key' on the actions menu for user with email `mdf-analytics@making-data-findable.iam.gserviceaccount.com`
    * Select JSON and submit the form 
    * Copy the file downloaded to compose/ckan/config/analytics-auth.json

4. Get it running
    * Copy the pre-prepared egg directories into the defra plugins to allow for an editable install
      * `cp -r .envs/dev/ckanext_defra.egg-info ckan-extensions/ckanext-defra/`
      * `cp -r .envs/dev/ckanext_defrareports.egg-info ckan-extensions/ckanext-defrareports/`
    * Alias ckan to localhost (required for working with datapusher)
        * Add `127.0.1.1      ckan` to `/etc/hosts` 
    * Bring the containers up `docker-compose -f development.yml up`
    * Visit http://ckan:5000
    * If ckan doesn't load after you first bring the containers up:
        * This is most likely caused by a race condition between the ckan container and the db.
        * Restarting the ckan container should sort it out `docker-compose -f development.yml up -d ckan`

5. Import Data
    
    TODO: This will change significantly once alpha is live
    
    * Stop the ckan and supervisor containers to stop them locking tables in the db
        * `docker-compose -f development.yml stop ckan`
        * `docker-compose -f development.yml stop supervisor`
    * SSH to the prototype `ssh vagrant@dd-find-proto.ukwest.cloudapp.azure.com`
    * Dump the db ``sudo -u postgres pg_dump ckan_default > /tmp/ckan-backup-`date +%F`.sql``
    * Tar the sql file ``tar -czvf "/tmp/ckan-backup-`date +%F`.tgz"  -C /tmp/ "ckan-backup-`date +%F`.sql"``
    * Exit back to your local machine `exit`
    * Copy the tar file locally ``scp vagrant@dd-find-proto.ukwest.cloudapp.azure.com:/tmp/ckan-backup-`date +%F`.tgz /tmp/``
    * Untar the sql ``tar -xzf /tmp/ckan-backup-`date +%F`.tgz -C /tmp/``
    * Ensure roles exists in the db (pass: ckan) `psql -h localhost -d postgres -p 5433 -U ckan_default -c 'CREATE USER postgres SUPERUSER;'`
    * Run the sql (pass: ckan) ``psql -h localhost -p 5433 -U ckan_default < /tmp/ckan-backup-`date +%F`.sql`` 
    * Restart all containers `docker-compose -f development.yml up -d`
    * You will also probably need to rebuild the solr search index `docker exec -it mdf-ckan /usr/local/bin/ckan-paster --plugin=ckan search-index rebuild -o --config=/etc/ckan/production.ini`
    
6. Setup Datastore
  * Set postgres permissions ``docker exec -it mdf-ckan /usr/local/bin/ckan-paster --plugin=ckan datastore set-permissions -c /etc/ckan/production.ini | psql -h db -U ckan_default --set ON_ERROR_STOP=1``
  * Add existing datasets to the datastore``docker exec -it mdf-ckan /usr/local/bin/ckan-paster --plugin=ckan datapusher submit_all -c /etc/ckan/production.ini``  
7. User
    * Create a superuser account for yourself ``docker exec -it mdf-ckan /usr/local/bin/ckan-paster --plugin=ckan sysadmin add <YOUR USERNAME> email=<YOUR EMAIL> name=<YOUR USERNAME> -c /etc/ckan/production.ini``
    

### Deploying to Azure

Until we have set up a proper container registry we deploy by creating an ssh tunnel to our azure container service and pointing to docker to it.

Note: You will need to set up ssh keys and get them added to the container service either on the Azure portal or ask a developer with access to help you.

To deploy:

1 Set the Google Analytics environment variables in your shell (request the details from a developer)
    * `export GOOGLE_ANALYTICS_SITE_ID=???`
    * `export GOOGLE_ANALYTICS_USERNAME=???`
    * `export GOOGLE_ANALYTICS_PASSWORD=???`
2. Log in to sentry and retrieve the dsn for the Making Data Findable project
3. Set the Sentry DSN environment variable `export SENTRY_DSN=???`
4. Set the Sendgrid password environment variable (ask a dev) `export SENDGRID_PASSWORD=???`
5. Create the tunnel `ssh dockeruser@51.141.98.150 -p 2200 -L 22375:127.0.0.1:2375`
6. Point docker to the remote service `export DOCKER_HOST=":22375"`
7. Bring the containers up `docker-compose -f production.yml up -d`
