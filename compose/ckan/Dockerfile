# See CKAN docs on installation from Docker Compose on usage
FROM debian:stretch
MAINTAINER Open Knowledge

# Install required system packages
RUN apt-get -q -y update \
    && DEBIAN_FRONTEND=noninteractive apt-get -q -y upgrade \
    && apt-get -q -y install \
        python-dev \
        python-pip \
        python-virtualenv \
        python-wheel \
        libpq-dev \
        libxml2-dev \
        libxslt-dev \
        libgeos-dev \
        libssl-dev \
        libffi-dev \
        postgresql-client \
        build-essential \
        git-core \
        vim \
        wget \
        supervisor \
    && apt-get -q clean \
    && rm -rf /var/lib/apt/lists/*

# Define environment variables
ENV CKAN_HOME /usr/lib/ckan
ENV CKAN_VENV $CKAN_HOME/venv
ENV CKAN_CONFIG /etc/ckan
ENV CKAN_STORAGE_PATH=/var/lib/ckan
ENV CKAN_VERSION=ckan-2.8.2

# Build-time variables specified by docker-compose.yml / .env
ARG CKAN_SITE_URL

# Create ckan user
RUN useradd -r -u 900 -m -c "ckan account" -d $CKAN_HOME -s /bin/false ckan

# Setup virtual environment for CKAN
RUN mkdir -p $CKAN_VENV $CKAN_CONFIG $CKAN_STORAGE_PATH && \
    virtualenv $CKAN_VENV && \
    ln -s $CKAN_VENV/bin/pip /usr/local/bin/ckan-pip &&\
    ln -s $CKAN_VENV/bin/paster /usr/local/bin/ckan-paster

# Setup CKAN
RUN git clone https://github.com/ckan/ckan.git $CKAN_VENV/src/ckan && \
    cd $CKAN_VENV/src/ckan && \
    git fetch && \
    git checkout $CKAN_VERSION
RUN ckan-pip install -U pip && \
    ckan-pip install --upgrade --no-cache-dir -r $CKAN_VENV/src/ckan/requirement-setuptools.txt && \
    ckan-pip install --upgrade --no-cache-dir -r $CKAN_VENV/src/ckan/requirements.txt && \
    ckan-pip install -e $CKAN_VENV/src/ckan/ && \
    ln -s $CKAN_VENV/src/ckan/ckan/config/who.ini $CKAN_CONFIG/who.ini && \
    cp -v $CKAN_VENV/src/ckan/contrib/docker/ckan-entrypoint.sh /ckan-entrypoint.sh && \
    chmod +x /ckan-entrypoint.sh && \
    chown -R ckan:ckan $CKAN_HOME $CKAN_VENV $CKAN_CONFIG $CKAN_STORAGE_PATH

# Defra specific

# Copy production.ini over so it's accessiblele during build
COPY ./compose/ckan/config/production.ini /etc/ckan/production.ini

# Install ckan
COPY ./compose/ckan/requirements.txt /requirements.txt
RUN /usr/lib/ckan/venv/bin/pip install -r /usr/lib/ckan/venv/src/ckan/dev-requirements.txt

# Install ckan extensions
RUN /usr/lib/ckan/venv/bin/pip install -r /requirements.txt

# Extra requirements files for ckan extensions
RUN /usr/lib/ckan/venv/bin/pip install -r /usr/lib/ckan/venv/src/ckanext-dcat/requirements.txt
RUN /usr/lib/ckan/venv/bin/pip install -r /usr/lib/ckan/venv/src/ckanext-spatial/pip-requirements.txt
RUN /usr/lib/ckan/venv/bin/pip install -r /usr/lib/ckan/venv/src/ckanext-harvest/dev-requirements.txt
RUN /usr/lib/ckan/venv/bin/pip install -r /usr/lib/ckan/venv/src/ckanext-harvest/pip-requirements.txt

# Defra plugin
COPY ./ckanext-defra /usr/lib/ckan/venv/src/ckanext-defra
RUN /usr/lib/ckan/venv/bin/pip install -r /usr/lib/ckan/venv/src/ckanext-defra/dev-requirements.txt

# Need to be root to create the egg file
USER root
RUN /usr/lib/ckan/venv/bin/pip install -e /usr/lib/ckan/venv/src/ckanext-defra/

# Copy init file
COPY ./compose/ckan/ckan-entrypoint.sh /ckan-entrypoint.sh
RUN chmod a+x /ckan-entrypoint.sh

RUN mkdir /var/log/ckan/

ENTRYPOINT ["/ckan-entrypoint.sh"]

USER ckan
EXPOSE 5000

CMD ["ckan-paster", "serve", "/etc/ckan/production.ini", "--reload"]
