# Defra finding data prototype/demo

This repo contains ansible scripts for setting up the [demonstration server](http://dd-find-proto.ukwest.cloudapp.azure.com/).

The process isn't faultless yet, and may require a bit of fiddliness to get up and running, but this instructions below should get you started.

## Installation

* Check out this repository
* `git clone git@gitlab.com:rossjones/defra-data-deploy.git && cd defra-data-deploy`.
* `mkdir src`
* `. setup_repos.sh`
* You probably need to change the Vagrantfile to another provider if you are not using Hyper-V
* `vagrant up`
* It's easiest to run these scripts inside the VM by using `vagrant ssh` and then `cd /vagrant/deploy && pip install ansible`
* The scripts are run individually to ensure they complete
* `ansible-playbook --connection=local -i production common.yml`
* `ansible-playbook --connection=local -i production postgres.yml`
* `ansible-playbook --connection=local -i production solr.yml`
* `ansible-playbook --connection=local -i production ckan.yml`

## How things are set up

```
Nginx -> Apache(WSGI) -> Postgres
                      |
                      -> Solr
```

The nginx as router, and Apache as apphost thing probably isn't ideal, but it's the bog-standard way of installing CKAN just because nginx is nicer for routing than Apache.  We _could_ set it up with nginx->gunicon/uwsgi/whatever but there's little need for the demo.

Most of the following will be set up by the Ansible scripts, but always helpful to know where stuff is.

    Nginx config is in `/etc/nginx/sites-enabled/ckan`
    Apache config is in `/etc/apache/sites-enabled/ckan_default.conf`
    The CKAN ini file is at `/etc/ckan/default/production.ini`

The virtualenv that the CKAN 'app' runs in is at `/usr/lib/ckan/default` and the source code for our extensions ends up at `/vagrant/src`. Don't forget to start the venv before doing 'stuff' (`. /usr/lib/ckan/default/bin/activate`).

The main extension we use is ckanext-defra which contains our code and templates and other modifications of the base CKAN install. The best place to start (after the [CKAN docs](https://docs.ckan.org/en/2.8/))  is in `ckanext-defra/ckanext/defra/plugin.py`.

## Useful commands

These are things we tend to need to do from time-to-time...

Restarting Apache .. `sudo service apache2 restart`

Access the database .. `sudo -u postgres psql ckan_default`

Restart solr .. `sudo service jetty8 restart`

Most of the interaction with administering CKAN is via `paster` commands.  Some useful ones are:

```
# Get a helpful list of command from a plugin
paster --plugin=ckan
# or
paster --plugin=ckanext-defra

# Get help for the ckan search-index command
paster --plugin=ckan help search-index
```
