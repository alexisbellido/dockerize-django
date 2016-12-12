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

COPY default.vcl /etc/varnish/default.vcl

EXPOSE 83 6082

# use ENTRYPOINT?
CMD ["varnishd", "-F", "-a", ":83", "-T", ":6082", "-f", "/etc/varnish/default.vcl", "-s", "malloc,1G"]
