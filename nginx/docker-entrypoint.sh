#! /bin/bash

sed -i -e "s|APP_HOST|$APP_HOST|g" -e "s|APP_PORT|$APP_PORT|g" /etc/nginx/conf.d/default.conf

nginx -g 'daemon off;'
