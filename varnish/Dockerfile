FROM debian:jessie
MAINTAINER Alexis Bellido <a@zinibu.com>

ARG DEBIAN_FRONTEND=noninteractive

RUN set -x \
  && apt-get -y update \
  && apt-get -y install apt-transport-https \
  && apt-get install -y curl \
  && curl https://repo.varnish-cache.org/GPG-key.txt | apt-key add - \
  && echo "deb https://repo.varnish-cache.org/debian/ jessie varnish-4.1" >> /etc/apt/sources.list.d/varnish-cache.list \
  && apt-get update \
  && apt-get -y install varnish

ENV WEB_HOST web_host
ENV WEB_PORT 80
ENV DOMAIN_NAME example.com
ENV SSL_WWW_REDIRECT 0

COPY default.vcl /etc/varnish/default.vcl
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

EXPOSE 83 6082

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
