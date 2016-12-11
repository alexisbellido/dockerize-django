FROM nginx:1.10.2
MAINTAINER Alexis Bellido <a@zinibu.com>

ENV APP_HOST app_host
ENV APP_PORT 8000

COPY default.conf.org /etc/nginx/conf.d/default.conf
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
