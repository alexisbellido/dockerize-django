FROM nginx:1.15.0
LABEL maintainer="Alexis Bellido <a@zinibu.com>"

ENV PROJECT_NAME project

COPY nginx.conf /etc/nginx/nginx.conf
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]