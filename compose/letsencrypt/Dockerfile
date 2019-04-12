FROM debian:jessie-backports

ARG CKAN_DOMAIN

RUN apt-get update \
  && apt-get install -y letsencrypt -t jessie-backports \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir -p /etc/letsencrypt/live/ckan \
  && openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/letsencrypt/live/privkey.pem \
    -out /etc/letsencrypt/live/fullchain.pem \
    -subj /CN=${CKAN_DOMAIN}
