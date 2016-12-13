Docker images to build a Django project
==========================================

A Django stack running with Docker.


Overview
==========================================

If running locally for development, it uses one HAProxy container to load balance containers running Varnish that cache Nginx in front Gunicorn. Usually just one Docker host takes care of all containers.

If running on AWS, it uses ELB to load balance containers running Varnish that cache Nginx in front Gunicorn. The default setup assumes three containers running on each Docker host: Varnish, Nginx and Gunicorn.

PostgreSQL
==========================================

access psql:

docker exec -it db1 psql -h db1 -U user1 -d db1

check mount and restore from db dump
docker inspect db1
docker exec -it db1 psql -h db1 -U user1 -d db1 -f /var/lib/postgresql/data/db1_11112016_0157.sql

gunicorn with django project
docker run -d --network=zinibu --env POSTGRES_USER=user1 --env POSTGRES_PASSWORD=user_secret --env POSTGRES_DB=db1 --hostname=db1 --name=db1 postgres:9.4


Nginx
==========================================

nginx proxying to gunicorn (final part of volume mapping directory, /usr/share/nginx/zinibu, matches PROJECT_NAME)

  ``docker run --network=zinibu -v /home/alexis/mydocker/zinibu:/usr/share/nginx/zinibu --env APP_HOST=app1 --env APP_PORT=8000 --env PROJECT_NAME=zinibu -p 33334:80 -d  --hostname=web1 --name=web1 alexisbellido/nginx:1.10.2``

Varnish
==========================================

  ``docker run --network=zinibu -v /home/alexis/mydocker/dockerize-django/varnish/default.vcl:/etc/varnish/default.vcl -p 33335:83 --hostname=cache1 --name=cache1 alexisbellido/varnish:4.1``

Django needs to allow Nginx or Varnish's probe won't work. Include this in your Django settings:
ALLOWED_HOSTS = ['*']

Of course, you can provide the hostname for Nginx.
Use curl from the Varnish container to the Nginx container to debug.


HAProxy
==========================================

https://hub.docker.com/_/haproxy/
The haproxy.cfg copied in Dockerfile is overriden if running via bind mount

haproxy non-ssl:
  ``docker run -d --network zinibu -v /home/alexis/mydocker/dockerize-django/haproxy/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg -p 35004:8998 -p 35005:80 -p 35006:443 --hostname=lb1 --name=lb1 alexisbellido/haproxy:v2``


Django project
==========================================


My Docker Hub user is *alexisbellido* and I'm calling my network *zinibu*:

Create a bridge network for your containers on your host.

  ``docker network create -d bridge zinibu``

Build the image for a Django/Python container in the django directory:

  ``docker build -t alexisbellido/python:v5 .``

Run the container passing parameters.

For Django development server:
  ``docker run -itd --network=zinibu -v /home/alexis/mydocker/zinibu:/root/zinibu -v /home/alexis/mydocker/djapps:/root/djapps --env PROJECT_NAME=zinibu --env SETTINGS_MODULE=locals3 --env POSTGRES_USER=user1 --env POSTGRES_PASSWORD=user_secret --env POSTGRES_DB=db1 --env POSTGRES_HOST=db1 -p 33332:8000 --hostname=app1-dev --name=app1-dev alexisbellido/python:3.5.2-slim development``

For Django via gunicorn (specifying how to map the port on the host):

  ``docker run -itd --network=zinibu -v /home/alexis/mydocker/zinibu:/root/zinibu -v /home/alexis/mydocker/djapps:/root/djapps --env PROJECT_NAME=zinibu --env SETTINGS_MODULE=locals3 --env POSTGRES_USER=user1 --env POSTGRES_PASSWORD=user_secret --env POSTGRES_DB=db1 --env POSTGRES_HOST=db1 -p 33333:8000 --hostname=app1 --name=app1 alexisbellido/python:3.5.2-slim production``


Note the environment variables:
SETTINGS_MODULE, used for DJANGO_SETTINGS_MODULE
PROJECT_NAME, the name of your project
PORT

You can inspect the logs of any running container (-f works like in tail) to confirm it's working as expected:
  ``docker logs -f CONTAINER``

SSH into a container to take a closer look:
  ``docker exec -it CONTAINER /bin/bash``

Find out details about run command used to start a container:
  ``docker inspect -f '{{.Config.Entrypoint}} {{.Config.Cmd}}' CONTAINER``
  ``docker inspect -f '{{.Config.Env}}' CONTAINER``

And to inspect everything about the container:
  ``docker inspect CONTAINER | less``
