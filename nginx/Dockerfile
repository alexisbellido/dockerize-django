FROM nginx:1.14.0
LABEL maintainer="Alexis Bellido <a@zinibu.com>"

ENV APP_HOST app
ENV APP_PORT 8000
ENV PROJECT_NAME project

COPY nginx.conf /etc/nginx/nginx.conf
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]