FROM debian:jessie-backports

RUN apt-get update \
  && apt-get install -y letsencrypt -t jessie-backports \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir -p /etc/letsencrypt/live/defra-making-data-findable.ukwest.cloudapp.azure.com \
  && openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/letsencrypt/live/defra-making-data-findable.ukwest.cloudapp.azure.com/privkey.pem \
    -out /etc/letsencrypt/live/defra-making-data-findable.ukwest.cloudapp.azure.com/fullchain.pem \
    -subj /CN=defra-making-data-findable.ukwest.cloudapp.azure.com
