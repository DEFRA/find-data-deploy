### Get up and running locally

1. Grab the repo
    ```
    git clone --recursive git@gitlab.com:nickross/defra-mdf.git
    cd defra-mdf
    ```

2. Grab the location data
    * Download the OS Open Names CSV from the [Ordinance Survey Website](https://www.ordnancesurvey.co.uk/opendatadownload/products.html#OPNAME)
    * Make a temporary directory to hold the data `mkdir compose/location/data/`
    * Unzip the downloaded csv to compose/location/data/
    * cd to the data dir `cd compose/location/data/`
    * Unzip the file `unzip opname_csv_gb.zip`
    * Merge all data into a single file for the go app `cat DATA/* > merged_results.csv`
    
3. Get it running
    * cd to the root project dir `cd ../../../`
    * Get a copy of the dev environment variables `cp .envs/dev/.env .`
    * Copy the pre-prepared egg directory into the defra plugin to allow for an editable install `cp -r .envs/dev/ckanext_defra.egg-info ckan-extensions/ckanext-defra/`
    * Alias ckan to localhost (required for working with datapusher)
        * Add `127.0.1.1      ckan` to `/etc/hosts` 
    * Bring the containers up `docker-compose -f development.yml up`
    * Visit http://localhost:5000
    * If ckan doesn't load after you first bring the containers up:
        * This is most likely caused by a race condition between the ckan container and the db.
        * Restarting the ckan container should sort it out `docker-compose -f development.yml up -d ckan`

4. Import Data
    
    TODO: This will change significantly once alpha is live
    
    * Stop the ckan and supervisor containers to stop them locking tables in the db
        * `docker-compose -f development.yml stop ckan`
        * `docker-compose -f development.yml stop supervisor`
    * SSH to the prototype `ssh vagrant@dd-find-proto.ukwest.cloudapp.azure.com`
    * Dump the db ``sudo -u postgres pg_dump ckan_default > /tmp/ckan-backup-`date +%F`.sql``
    * Tar the sql file ``tar -czvf "/tmp/ckan-backup-`date +%F`.tgz"  -C /tmp/ "ckan-backup-`date +%F`.sql"``
    * Exit back to your local machine `exit`
    * Copy the tar file locally `scp vagrant@dd-find-proto.ukwest.cloudapp.azure.com:/tmp/ckan-backup-`date +%F`.tgz /tmp/`
    * Untar the sql ``tar -xzf /tmp/ckan-backup-`date +%F`.tgz -C /tmp/``
    * Ensure roles exists in the db (pass: ckan) `psql -h localhost -d postgres -p 5433 -U ckan_default -c 'CREATE USER postgres SUPERUSER;'`
    * Run the sql (pass: ckan) ``psql -h localhost -p 5433 -U ckan_default < /tmp/ckan-backup-`date +%F`.sql`` 
    * Restart all containers `docker-compose -f development.yml up -d`
    * You will also probably need to rebuild the solr search index `docker exec -it mdf-ckan /usr/local/bin/ckan-paster --plugin=ckan search-index rebuild -o --config=/etc/ckan/production.ini`
    
5. Setup Datastore
  * Set postgres permissions ``docker exec -it mdf-ckan /usr/local/bin/ckan-paster --plugin=ckan datastore set-permissions -c /etc/ckan/production.ini | psql -h db -U ckan_default --set ON_ERROR_STOP=1``
  
6. User
    * Create a superuser account for yourself ``docker exec -it mdf-ckan /usr/local/bin/ckan-paster --plugin=ckan sysadmin add <YOUR USERNAME> email=<YOUR EMAIL> name=<YOUR USERNAME> -c /etc/ckan/production.ini``
    
