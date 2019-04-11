#FROM postgres:9.6
FROM mdillon/postgis:10-alpine

# Allow connections; we don't map out any ports so only linked docker containers can connect
RUN echo "host all  all    0.0.0.0/0  md5" >> /var/lib/postgresql/data/pg_hba.conf

# Include datastore setup scripts
ADD ./compose/postgresql/docker-entrypoint-initdb.d /docker-entrypoint-initdb.d
