Django Project
========================================

Just the basics to launch a Docker-based Django project with Gunicorn for production and Django runserver for development.

No need for `gosu <https://github.com/tianon/gosu>`_ because there's no need to step down from the root user during container startup, specifically in the *ENTRYPOINT*.

Use multi-stage build passing an ssh private key to access any private repositories, either via git or pip. See Dockerfile.

.. code-block:: bash

  $ docker build --build-arg SSH_PRIVATE_KEY="$(cat ~/.ssh/id_rsa)" -t username/django:2.0.6 .

Once you've built the image you can push it to Docker hub.

.. code-block:: bash

  $ docker login
  $ docker push username/django:2.0.6

These commands run bind mount the Django project from the same directory where the Dockerfile for Django is so that $PWD/project, which can also be expressed as "$(pwd)"/project, is the outer project directory mapped to /root/project in the container. This is useful for changing code during development but at the end the project code should be part of the image.

.. code-block:: bash
  $ docker run -it --rm --mount type=bind,source="$(pwd)"/project,target=/root/project -p 8000:8000 username/django:2.0.6 /bin/bash

This uses the absolute path to the project.

.. code-block:: bash

  $ docker run -it --rm --mount type=bind,source=/path/to/outer/project,target=/root/project -p 8000:8000 username/django:2.0.6 /bin/bash

If you mount a bind mount or non-empty volume into a directory in the container in which some files or directories exist, these files or directories are obscured by the mount. Read more about `volumes and bind mounts <https://docs.docker.com/storage/#good-use-cases-for-volumes>`_.

Run development server in foreground mode with support for interactive processes (-it) and removal on exit (--rm).

.. code-block:: bash

  $ docker run -it --rm -p 8000:8000 username/django:2.0.6 development

Note development and production are using media and static volumes, the same that Nginx uses on the host. This is important for Django collectstatic.

Run development server in detached mode on a bridge network and mapping project directory for development. Once development is done it will be enough with source code included in the image.

.. code-block:: bash

  $ docker run -d --network=project_network --mount type=bind,source=/path/to/outer/project,target=/root/project --mount source=media,target=/root/project/media --mount source=static,target=/root/project/static --env POSTGRES_USER=user1 --env POSTGRES_PASSWORD=user_secret --env POSTGRES_DB=db1 --env POSTGRES_HOST=dbserver1 --name=app1 -p 8000:8000 username/django:2.0.6 development

If you are in the same directory as the Django Dockerfile you can use $PWD/project instead for /path/to/outer/project.

.. code-block:: bash

  $ docker run -d --network=project_network --mount type=bind,source=$PWD/project,target=/root/project --mount source=media,target=/root/project/media --mount source=static,target=/root/project/static --env POSTGRES_USER=user1 --env POSTGRES_PASSWORD=user_secret --env POSTGRES_DB=db1 --env POSTGRES_HOST=dbserver1 --name=app1 -p 8000:8000 username/django:2.0.6 development

Run production in detached mode.

.. code-block:: bash

  $ docker run -d --network=project_network --mount source=media,target=/root/project/media --mount source=static,target=/root/project/static --env POSTGRES_USER=user1 --env POSTGRES_PASSWORD=user_secret --env POSTGRES_DB=db1 --env POSTGRES_HOST=dbserver1 --name=app1 -p 8000:8000 username/django:2.0.6 production

If you pass any parameter not considered by the entrypoint script (docker-entrypoint.sh), it will be just executed with exec "$@".

Execute commands on running container. Use docker-entrypoint.sh to activate Python environment and set environment for Django.

.. code-block:: bash

  $ docker exec -it app1 /usr/local/bin/docker-entrypoint.sh pip freeze
  $ docker exec -it app1 docker-entrypoint.sh django-admin help
  $ docker exec -it app1 docker-entrypoint.sh django-admin collectstatic
  
Create initial database and super user.
  
.. code-block:: bash

  $ docker exec -it app1 docker-entrypoint.sh django-admin migrate
  $ docker exec -it app1 docker-entrypoint.sh django-admin createsuperuser


You can get into the container, verify the Python packages installed, because the virtual environment is activated by the entrypoint script, and confirm where that environment lives (/env/bin/pip with the provided image).

.. code-block:: bash

  $ docker exec -it app1 docker-entrypoint.sh /bin/bash
  $ pip freeze
  $ which pip

Use of the full path is optional because it should already be in the $PATH.

.. code-block:: bash

  $ python -m django --version

The -m <module-name> option searches sys.path for the named module and execute its contents as the __main__ module.
There's `a bug <https://github.com/docker/for-mac/issues/307>`_ that causes Docker not to follow the logs making it difficult to see console output and debug using Django's development server or Gunicorn from the Django application. To work around this use Django's logging system. Start by adding this to your settings file:

.. code-block:: bash

  import logging

  LOGGING = {
      'version': 1,
      'disable_existing_loggers': False,
      'formatters': {
          'verbose': {
              'format': '%(levelname)s %(asctime)s %(module)s %(process)d %(thread)d %(message)s'
          },
      },
      'handlers': {
          'console': {
              'level': 'INFO',
              'class': 'logging.FileHandler',
              'filename': '/var/log/debug.log',
              'formatter': 'verbose'
          },
      },
      'loggers': {
          '': {
              'handlers': ['console'],
              'level': 'INFO',
          }
      },
  }

And then you can add logging calls in the appropiate parts of your code. I'm adding pretty printing here:

.. code-block:: bash

  import pprint
  logger = logging.getLogger(__name__)
  logger.info(pprint.pformat(vars(object)))

See `Django logging documentation <https://docs.djangoproject.com/en/2.0/topics/logging/`_.

https://docs.python.org/3/using/cmdline.html#envvar-PYTHONUNBUFFERED and environment variable PYTHONUNBUFFERED set to 1 is the solution to using docker logs with print. Note that this works from views and other parts but not from settings.py. Use logging for better control.

You may need to change ALLOWED_HOSTS in the Django settings file.

  ``ALLOWED_HOSTS = ['*']``

Configs
======================

Use compose/animals.txt in compose/basic-django.yml as Docker config.

See `Docker configs <https://docs.docker.com/compose/compose-file/#configs-configuration-reference>`_.

Secrets
======================

Copy compose/config.yaml.orig to compose/config.yaml (note this is in .gitignore so it won't be pushed to the repository) to use with compose/basic-django.yml as Docker secret.

See `Docker secrets <https://docs.docker.com/compose/compose-file/#secrets-configuration-reference>`_.

Overview
------------------------------------------

Most Docker commands in this document should be run from the main project directory and will refer to it as $PWD.

If running locally for development, it uses one HAProxy container to load balance containers running Varnish that cache Nginx in front Gunicorn. Usually just one Docker host takes care of all containers.

If running on AWS, it uses ELB to load balance containers running Varnish that cache Nginx in front Gunicorn. The default setup assumes three containers running on each Docker host: Varnish, Nginx and Gunicorn.

My Docker Hub user is *username* and I'm calling my network *project_network*:

Create a bridge network for your containers on your host. This step is unnecessary if using the provided Docker Compose compose-complete/docker-compose.yml, which creates its own network.

.. code-block:: bash

  $ docker network create -d bridge project_network

The examples below assume a basic architecture like this:

.. code-block:: bash

  lb --> cache1 --> web1 --> app1

- lb: load balancer, optional HAProxy for local development
- cache1: Varnish. There are alternative versions with SSL or mapping a VCL file
- web1: Nginx
- app1: Django application running on Gunicorn

PostgreSQL
------------------------------------------

Run the `official PostgreSQL image <https://hub.docker.com/_/postgres/>`_ passing parameters.

Create volume for database files.

.. code-block:: bash

  $ docker volume create database

.. code-block:: bash

  $ docker run -d --network=project_network --mount source=database,target=/var/lib/postgresql/data --env POSTGRES_USER=user1 --env POSTGRES_PASSWORD=user_secret --env POSTGRES_DB=db1 --name=dbserver1 postgres:10.4

Using a volume this way the container can be recreated while the database persists in the volume. See `Stack Overflow <https://stackoverflow.com/questions/41637505/how-to-persist-data-in-a-dockerized-postgres-database-using-volumes>`_ and `PostgreSQL image <https://hub.docker.com/_/postgres/>`_.

Connect via psql from the same container; there's no need for password.

.. code-block:: bash

  $ docker exec -it dbserver1 psql -U user1 -d db1

Connect via psql from other container on the same network.

.. code-block:: bash

  $ docker run -it --rm --network=project_network postgres:10.4 psql -h dbserver1 -U user1 -d db1

.. code-block:: bash

  $ docker exec -it db1 psql -h dbserver1 -U user1 -d db1

To restore from a dump created with just psql.

.. code-block:: bash

  $ docker exec -it dbserver1 psql -h dbserver1 -U user1 -d db1 -f /tmp/db1.sql

Create compressed database dump from the container (note this is saving to /tmp just as an example, you should use a non-public location).

.. code-block:: bash

  $ docker exec -it dbserver1 /bin/bash
  $ pg_dump -Fc -v -h dbserver1 -U user1 db1 > /tmp/db1-$(date +"%m%d%Y-%H%M%S").dump

Create compressed database dump from AWS RDS.

.. code-block:: bash

  $ pg_dump -Fc -v -h somehostname.us-east-1.rds.amazonaws.com -U user dbname > dbname.dump

Copy a database dump from a container (db2) to the current directory on the host.

.. code-block:: bash

  $ docker cp dbserver1:/tmp/dbname.dump .

Use docker cp to copy a database dump, created with pg_dump, and restore it to a container.

.. code-block:: bash

  $ docker cp /home/user/backup/dbname.dump dbserver1:/tmp/dbname.dump

Restore using -c to drop database objects before recreating them.  You may need to ssh into the container before you can restore with pg_restore.

.. code-block:: bash

  $ docker exec -it dbserver1 /bin/bash
  $ pg_restore -v -c -h dbserver1 -U user1 -d db1 /tmp/dbname.dump

You can also use Docker Compose to launch all the containers for your stack at once.

.. code-block:: bash

  $ cd compose-complete
  $ docker-compose up

This connects to a container creater with Docker Compose and doesn't need to ssh first.

.. code-block:: bash

  $ docker-compose exec db1 pg_restore -v -c -h dbserver1 -U user1 -d db1 /tmp/dbname.dump

Don't forget to delete the temporary database by logging in to the container and deleting it from bash.

.. code-block:: bash

  $ docker exec -it dbserver1 /bin/bash

Redis
------------------------------------------

.. code-block:: bash

  $ docker run -d --network=project_network --name=redis1 redis:3.2.6

Exposes port 6379 so you can connect from the application container on the same network using the name.

You can monitor connections with:

.. code-block:: bash

  $ docker exec -it redis1 redis-cli monitor

Nginx
------------------------------------------

Nginx proxying to Gunicorn (final part of volume mapping directory, /usr/share/nginx/project, matches PROJECT_NAME).

The Django project, as created by django-admin startproject, is in a directory with this structure:

.. code-block:: bash

  - project (this is /path/to/outer/project, just a container for the project and its name doesn't matter to Django)
    -- sampleapp1
    -- sampleapp2
    -- manage.py
    -- media (placeholder with sample file, just for creating image)
    -- project (inner directory, actual Python package to import anything inside project)
    -- static (placeholder with sample file, just for creating image)

Nginx container creates an empty root /usr/share/nginx/public as the parent of the mounted media and static volumes so no Python code can be accessed.

Note that a Django app, such as sampleapp1, can be a sibling of manage.py or be installed via pip so that it's in Python's module search path.

Build the image from the directory that contains the Nginx Dockerfile.

.. code-block:: bash

  $ docker build -t username/nginx:1.15.0 .

Create volumes for media and static.

.. code-block:: bash

  $ docker volume create media
  $ docker volume create static

If needed use a helper, temporary, container to copy files from host to volumes. This doesn't need to keep on running. Using busybox because is small.

.. code-block:: bash

  $ docker run --mount source=media,target=/media --mount source=static,target=/static --name helper busybox true

Copy some files from host to volumes using the helper container.

.. code-block:: bash

  $ docker cp /host/static/file1.png helper:static/file1.png
  $ docker cp /host/media/file2.png helper:media/file2.png

And now that you copied the files into your volumes you can remove the helper container.

.. code-block:: bash

  $ docker rm helper

Start Nginx container using the media and static volumes.

  $ docker run -d --network=project_network --mount source=media,target=/usr/share/nginx/public/media --mount source=static,target=/usr/share/nginx/public/static --env APP_HOST=app1 -p 33334:80 --name=web1 username/nginx:1.15.0

If you want to use original media and static inside the project directory you could bind mount the project directory but you'll lose the benefits of using Docker volumes. Not recommended for production.

.. code-block:: bash

  $ docker run -d --network=project_network --mount source=/path/to/outer/project,target=/root/project --env APP_HOST=app1 -p 33334:80 --name=web1 username/nginx:1.15.0

Try test configuration with nginx.conf ($PWD assumes the file is in the current directory).

.. code-block:: bash

  $ docker run -d --network=project_network --mount type=bind,source=$PWD/nginx.conf,target=/etc/nginx/nginx.conf --mount source=media,target=/usr/share/nginx/public/media --mount source=static,target=/usr/share/nginx/public/static --env APP_HOST=app1 -p 33334:80 --name=web1 username/nginx:1.15.0

Now make changes in nginx.conf in host and reload Nginx in container.

.. code-block:: bash

  $ docker exec -it web1 /etc/init.d/nginx reload

Using sed to replace environment variables in a configuration file.

.. code-block:: bash

  $ sed -i -e "s|APP_HOST|$APP_HOST|g" -e "s|APP_PORT|$APP_PORT|g" -e "s|PROJECT_NAME|$PROJECT_NAME|g" /etc/nginx/nginx.conf

To create a self-signed SSL certificate
------------------------------------------

When asked for a fully qualified domain name (FQDN) you can enter subdomain.example.com or *.example.com

.. code-block:: bash

  $ mkdir ssl
  $ cd ssl
  $ openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout example_com.key -out example_com.crt
  $ cat example_com.crt example_com.key > example_com.pem


Create .pem to use with HAProxy from Comodo PositiveSSL
------------------------------------------

For this example we're creating a new file at /srv/haproxy/ssl/example_com.pem using the key file generated when requesting the certificate and the bundle and crt files provided by Comodo.

.. code-block:: bash

  $ cd /srv/haproxy/ssl
  $ rm example_com.pem
  $ cat example_com.key >> example_com.pem
  $ cat example_com.crt >> example_com.pem
  $ cat example_com.ca-bundle >> example_com.pem


Varnish
------------------------------------------

The provided default.vcl exposes a /varnishcheck URL to be used by load balancers health checks. Varnish uses std.healthy(req.backend_hint) to return a value based on health of its backend server.

To pass parameters to modify the included VCL:

.. code-block:: bash

  $ docker run -d --network=project_network -p 33345:83 --env WEB_HOST=web1 --env WEB_PORT=80 --env DOMAIN_NAME=example.com --name=cache1 username/varnish:4.1

To pass parameters to modify the included VCL and redirect to SSL and www version:

.. code-block:: bash

  $ docker run -d --network=project_network -p 33355:83 --env WEB_HOST=web1 --env WEB_PORT=80 --env DOMAIN_NAME=example.com --env SSL_WWW_REDIRECT=1 --name=cache1-ssl username/varnish:4.1

To map an existing VCL file:

.. code-block:: bash

  $ docker run -d --network=project_network -v /home/alexis/mydocker/dockerize-django/varnish/default-test.vcl:/etc/varnish/default.vcl -p 33335:83 --env WEB_HOST=web1 --env WEB_PORT=80 --env DOMAIN_NAME=example.com --name=cache-map-1 username/varnish:4.1

Django needs to allow Nginx or Varnish's probe won't work. Include this in your Django settings:

  ``ALLOWED_HOSTS = ['*']``

Of course, you can provide the hostname for Nginx.
Use curl from the Varnish container to the Nginx container to debug.

Build the image from the directory contains the corresponding Dockerfile, with:

.. code-block:: bash

  $ docker build -t username/varnish:4.1 .


HAProxy
------------------------------------------

haproxy non-ssl:

.. code-block:: bash

  $ docker run -d --network zinibu -v /home/alexis/mydocker/dockerize-django/haproxy/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg -p 35004:8998 -p 35005:80 -p 35006:443 --name=lb username/haproxy:1.6.10

Default HAProxy stats at http://example.com:35004/admin?stats (user: admin, password: admin)

haproxy ssl:

.. code-block:: bash

  $ docker run -d --network zinibu -v /home/alexis/mydocker/ssl/example_com.pem:/usr/local/etc/haproxy/ssl/example_com.pem -v /home/alexis/mydocker/dockerize-django/haproxy/haproxy-ssl.cfg:/usr/local/etc/haproxy/haproxy.cfg -p 35104:8998 -p 35105:80 -p 35106:443 --name=lb-ssl username/haproxy:1.6.10

Default HAProxy stats at http://example.com:35104/admin?stats  (user: admin, password: admin)

haproxy.cfg copied in Dockerfile is overriden when running via bind mount.

Build the image from the haproxy directory, which contains the corresponding Dockerfile, with:

.. code-block:: bash

  $ docker build -t username/haproxy:1.6.10 .


Ansible
------------------------------------------

Some Ansible examples that assume you are running as root, the control machine has its public key on the remote machines' ``~/.ssh/authorized_keys``, and the remote machines have ssh authentication setup for GitHub and any other remote server used.

.. code-block:: bash

   $ pip install ansible

Running git clone from GitHub.

.. code-block:: bash

  $ ansible all -m git -a "repo=git@github.com:username/django-zinibu-skeleton.git dest=/root/django-apps/django-zinibu-skeleton version=master accept_hostkey=yes"


Useful commands
------------------------------------------

Replace CONTAINER with a container name or ID.

You can inspect the logs of any running container (-f works like in tail) to confirm it's working as expected:

.. code-block:: bash

  $ docker logs -f CONTAINER

Connect to a container.

.. code-block:: bash

  $ docker exec -it CONTAINER /bin/bash

Connect to a running container using the entrypoint. In a Django container this will take care of activating the virtual environment.

  .. code-block:: bash

    $ docker exec -it CONTAINER docker-entrypoint.sh /bin/bash

Find out details about run command used to start a container:

.. code-block:: bash

  $ docker inspect -f '{{.Config.Entrypoint}} {{.Config.Cmd}}' CONTAINER
  $ docker inspect -f '{{.Config.Env}}' CONTAINER

And to inspect everything about the container.

.. code-block:: bash

  $ docker inspect CONTAINER | less

Remove stopped containers.

  .. code-block:: bash

    $ docker rm $(docker ps -aq)

Remove images without tags.

.. code-block:: bash

  $ docker rmi $(docker images -f dangling=true -q)

You can detach from a running container, the container will continue running, with CTRL+p CTRL+q and then attach back.

.. code-block:: bash

  $ docker attach CONTAINER

The container had to be started (docker run) with -it for the key sequence to work. Use CTRL+c or exit to stop the container. See `docker attach <https://docs.docker.com/engine/reference/commandline/attach/>`_.

Troubleshooting
------------------------------------------

  * When forwarding ssh agent into the container, make sure that the private key file from the host is the one loaded by ssh-agent. You may need to use ``ssh-add`` to list, delete and/or re-add identities (private keys). This may also be needed if the host is restarted and the containers can't remount the key data.