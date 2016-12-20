Docker images to build a Django project
==========================================

A Django stack running with Docker.


Overview
==========================================

If running locally for development, it uses one HAProxy container to load balance containers running Varnish that cache Nginx in front Gunicorn. Usually just one Docker host takes care of all containers.

If running on AWS, it uses ELB to load balance containers running Varnish that cache Nginx in front Gunicorn. The default setup assumes three containers running on each Docker host: Varnish, Nginx and Gunicorn.

My Docker Hub user is *alexisbellido* and I'm calling my network *zinibu*:

Create a bridge network for your containers on your host.

  ``docker network create -d bridge zinibu``


The examples below assume a basic architecture like this:

lb --> cache1 --> web1 --> app1

lb: load balancer, optional HAProxy for local development.
cache1: Varnish. There are alternative versions with SSL or mapping a VCL file.
web1: Nginx.
app1: Django application running on Gunicorn.


PostgreSQL
==========================================

Run the container passing parameters.

  ``docker run -d --network=zinibu --env POSTGRES_USER=user1 --env POSTGRES_PASSWORD=user_secret --env POSTGRES_DB=db1 --hostname=db1 --name=db1 postgres:9.4``

Access psql:

  ``docker exec -it db1 psql -h db1 -U user1 -d db1``

Use docker cp to copy a dump of the database to the container and restore it.

  ``docker exec -it db1 psql -h db1 -U user1 -d db1 -f /tmp/db1.sql``

Don't forget to delete the temporary database by logging in to the container and deleting it from bash.

  ``docker exec -it /bin/bash``


Python and Django
==========================================

Run the container passing parameters.

For Django development server:
  ``docker run -d --network=zinibu -v /home/alexis/mydocker/zinibu:/root/zinibu -v /home/alexis/mydocker/djapps:/root/djapps --env PROJECT_NAME=zinibu --env SETTINGS_MODULE=locals3 --env POSTGRES_USER=user1 --env POSTGRES_PASSWORD=user_secret --env POSTGRES_DB=db1 --env POSTGRES_HOST=db1 -p 33332:8000 --hostname=app1-dev --name=app1-dev alexisbellido/python:3.5.2-slim development``

For Django via gunicorn (specifying how to map the port on the host):

  ``docker run -d --network=zinibu -v /home/alexis/mydocker/zinibu:/root/zinibu -v /home/alexis/mydocker/djapps:/root/djapps --env PROJECT_NAME=zinibu --env SETTINGS_MODULE=locals3 --env POSTGRES_USER=user1 --env POSTGRES_PASSWORD=user_secret --env POSTGRES_DB=db1 --env POSTGRES_HOST=db1 -p 33333:8000 --hostname=app1 --name=app1 alexisbellido/python:3.5.2-slim production``


Note the environment variables:
SETTINGS_MODULE, used for DJANGO_SETTINGS_MODULE
PROJECT_NAME, the name of your project
PORT

Build the image from the nginx directory, which contains the corresponding Dockerfile, with:

  ``docker build -t alexisbellido/3.5.2-slim .``


Check logs of running container (-f works like in tail) to confirm it's working as expected:

  ``docker logs -f CONTAINER``

Make sure to check for ALLOWED_HOSTS issues in the Django settings file:

  ``ALLOWED_HOSTS = ['*']``


Nginx
==========================================

Nginx proxying to Gunicorn (final part of volume mapping directory, /usr/share/nginx/zinibu, matches PROJECT_NAME)

  ``docker run -d --network=zinibu -v /home/alexis/mydocker/zinibu:/usr/share/nginx/zinibu --env APP_HOST=app1 --env APP_PORT=8000 --env PROJECT_NAME=zinibu -p 33334:80 --hostname=web1 --name=web1 alexisbellido/nginx:1.10.2``

Build the image from the nginx directory, which contains the corresponding Dockerfile, with:

  ``docker build -t alexisbellido/nginx:1.10.2 .``


To create a self-signed SSL certificate
========================================

When asked for a fully qualified domain name (FQDN) you can enter subdomain.example.com or *.example.com

  ``$ mkdir ssl``
  ``$ cd ssl``
  ``$ openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout example_com.key -out example_com.crt``
  ``$ cat example_com.crt example_com.key > example_com.pem``


Create .pem to use with HAProxy from Comodo PositiveSSL
=========================================================

For this example we're creating a new file at /srv/haproxy/ssl/example_com.pem using the key file generated when requesting the certificate and the bundle and crt files provided by Comodo.

  ``$ cd /srv/haproxy/ssl``
  ``$ rm example_com.pem``
  ``$ cat example_com.key >> example_com.pem``
  ``$ cat example_com.crt >> example_com.pem``
  ``$ cat example_com.ca-bundle >> example_com.pem``


Varnish
==========================================

To pass parameters to modify the included VCL:

  ``docker run -d --network=zinibu -p 33345:83 --env WEB_HOST=web1 --env WEB_PORT=80 --env DOMAIN_NAME=example.com --hostname=cache1 --name=cache1 alexisbellido/varnish:4.1``

To pass parameters to modify the included VCL and redirect to SSL and www version:

  ``docker run -d --network=zinibu -p 33355:83 --env WEB_HOST=web1 --env WEB_PORT=80 --env DOMAIN_NAME=example.com --env SSL_WWW_REDIRECT=1 --hostname=cache1-ssl --name=cache1-ssl alexisbellido/varnish:4.1``

To map an existing VCL file:

  ``docker run -d --network=zinibu -v /home/alexis/mydocker/dockerize-django/varnish/default.vcl:/etc/varnish/default.vcl -p 33335:83 --hostname=cache-map-1 --name=cache-map-1 alexisbellido/varnish:4.1``

Django needs to allow Nginx or Varnish's probe won't work. Include this in your Django settings:

  ``ALLOWED_HOSTS = ['*']``

Of course, you can provide the hostname for Nginx.
Use curl from the Varnish container to the Nginx container to debug.

Build the image from the nginx directory, which contains the corresponding Dockerfile, with:

  ``docker build -t alexisbellido/varnish:4.1 .``


HAProxy
==========================================

haproxy non-ssl:
  ``docker run -d --network zinibu -v /home/alexis/mydocker/dockerize-django/haproxy/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg -p 35004:8998 -p 35005:80 -p 35006:443 --hostname=lb --name=lb alexisbellido/haproxy:1.6.10``

Default HAProxy stats at http://example.com:35004/admin?stats (user: admin, password: admin)

haproxy ssl:
  ``docker run -d --network zinibu -v /home/alexis/mydocker/ssl/example_com.pem:/usr/local/etc/haproxy/ssl/example_com.pem -v /home/alexis/mydocker/dockerize-django/haproxy/haproxy-ssl.cfg:/usr/local/etc/haproxy/haproxy.cfg -p 35104:8998 -p 35105:80 -p 35106:443 --hostname=lb-ssl --name=lb-ssl alexisbellido/haproxy:1.6.10``

Default HAProxy stats at http://example.com:35104/admin?stats  (user: admin, password: admin)

haproxy.cfg copied in Dockerfile is overriden when running via bind mount.

Build the image from the haproxy directory, which contains the corresponding Dockerfile, with:

  ``docker build -t alexisbellido/haproxy:1.6.10 .``

  
Useful commands
==========================================

You can inspect the logs of any running container (-f works like in tail) to confirm it's working as expected:
  ``docker logs -f CONTAINER``

SSH into a container to take a closer look:
  ``docker exec -it CONTAINER /bin/bash``

Find out details about run command used to start a container:
  ``docker inspect -f '{{.Config.Entrypoint}} {{.Config.Cmd}}' CONTAINER``
  ``docker inspect -f '{{.Config.Env}}' CONTAINER``

And to inspect everything about the container:
  ``docker inspect CONTAINER | less``
