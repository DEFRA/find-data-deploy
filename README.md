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
    * Bring the containers up `docker-compose -f development.yml up`
    * Visit http://localhost:5000

4. Troubleshooting
    * If ckan doesn't load after you first bring the containers up:
        * This is most likely caused by a race condition between the ckan container and the db.
        * Restarting the ckan container should sort it out `docker-compose -f development.yml up -d ckan`
