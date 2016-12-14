#! /bin/bash

sed -i -e "s|WEB_HOST|$WEB_HOST|g" -e "s|WEB_PORT|$WEB_PORT|g" -e "s|DOMAIN_NAME|$DOMAIN_NAME|g" /etc/varnish/default.vcl

if [ "$SSL_WWW_REDIRECT" == "1" ]; then
	sed -i -e 's|#SED||g' /etc/varnish/default.vcl
fi

varnishd -F -a :83 -T :6082 -f /etc/varnish/default.vcl -s malloc,1G
