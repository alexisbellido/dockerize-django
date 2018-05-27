Dockerize a Django Project
==================================================

A Django stack running with Docker.

See also the `Ansible and Django <https://github.com/alexisbellido/ansible-and-docker/>`_ project.

Overview
------------------------------------------

Most Docker commands in this document should be run from the main project directory and will refer to it as $PWD.

If running locally for development, it uses one HAProxy container to load balance containers running Varnish that cache Nginx in front Gunicorn. Usually just one Docker host takes care of all containers.

If running on AWS, it uses ELB to load balance containers running Varnish that cache Nginx in front Gunicorn. The default setup assumes three containers running on each Docker host: Varnish, Nginx and Gunicorn.

My Docker Hub user is *alexisbellido* and I'm calling my network *project_network*:

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

.. code-block:: bash

  $ docker run -d --network=project_network --env POSTGRES_USER=user1 --env POSTGRES_PASSWORD=user_secret --env POSTGRES_DB=db1 --name=dbserver1 postgres:10.4

Connect via psql.

From other container on the same network

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


Python and Django
------------------------------------------

This image contains openssh-client and the examples below use a data volume to forward the host's ssh agent to the container. This is helpful if the container needs to use ssh to connect to other servers (like private git repositories or GitHub) using the host's ssh key. The key parameters in the ``docker run`` command are ``-v ~/.ssh/id_rsa:/root/.ssh/id_rsa -v $SSH_AUTH_SOCK:/run/ssh_agent -e SSH_AUTH_SOCK=/run/ssh_agent``.

Once a container is running and assuming your host has its private key authorized on example.com or github.com you can test the ssh connection from the container.

.. code-block:: bash

  $ ssh user@example.com
  $ ssh -T git@github.com

The image's entrypoint (*/usr/local/bin/docker-entrypoint.sh*, copied to the container and defined with ENTRYPOINT in the Dockerfile) always sets the Python virtual environment first and then accepts parameters that can be passed at the end of the docker run command. If no parameter is passed, the value of CMD in the Dockerfile is used (usually "development").

Here are some of the parameters the entrypoint accepts:

- *development* runs Django development server.
- *production* runs Django with Gunicorn and accepts an optional second paramater --log-level=debug or --log-level=critical. If the second parameter is not passed --log-level=info is assumed.
- *update_index* runs Haystack's update_index and accepts an optional second parameter used as --age. See Haystack's help for more details.
- *shell* runs Django shell.
- *setenv* does nothing after activating the virtual the Python environment, useful when run from inside the container, see notes about running Django commands below.
- *collectstatic* runs Django's collectstatic without including admin files.
- *collectstatic-all* runs Django's collectstatic including admin files.
- *building* does nothing; it's only used when building the Docker image.

If you pass any parameter not considered by the entrypoint script, it will be just executed with exec "$@".

Note that the environment variable PROJECT_NAME has to match with the name used inside the main project directory (*django-project* in the examples listed here) to follow the directory structure created by Django's django-admin startproject.

Run a Django development server passing the parameter *development*:

.. code-block:: bash

  $ docker run -d --network=project_network -w /root -v ~/.ssh/id_rsa:/root/.ssh/id_rsa -v $SSH_AUTH_SOCK:/run/ssh_agent -e SSH_AUTH_SOCK=/run/ssh_agent -v "$PWD"/django-project:/root/django-project -v "$PWD"/django-apps:/root/django-apps --env PROJECT_NAME=django-project --env SETTINGS_MODULE=locals3 --env POSTGRES_USER=user1 --env POSTGRES_PASSWORD=user_secret --env POSTGRES_DB=db1 --env POSTGRES_HOST=db1 -p 33332:8000 --name=app1-dev alexisbellido/django:1.11 development

To use Redis pass REDIS_HOST and, for the sake of being implicit, REDIS_PORT, with the same development server:

.. code-block:: bash

  $ docker run -d --network=project_network -w /root -v ~/.ssh/id_rsa:/root/.ssh/id_rsa -v $SSH_AUTH_SOCK:/run/ssh_agent -e SSH_AUTH_SOCK=/run/ssh_agent -v "$PWD"/django-project:/root/django-project -v "$PWD"/django-apps:/root/django-apps --env PROJECT_NAME=django-project --env SETTINGS_MODULE=locals3 --env POSTGRES_USER=user1 --env POSTGRES_PASSWORD=user_secret --env POSTGRES_DB=db1 --env POSTGRES_HOST=db1 --env REDIS_HOST=redis1 --env REDIS_PORT=6379 -p 33332:8000 --name=app1-dev alexisbellido/django:1.11 development

For Django via gunicorn (specifying how to map the port on the host) and using Redis, use the *production* parameter:

.. code-block:: bash

  $ docker run -d --network=project_network -w /root -v ~/.ssh/id_rsa:/root/.ssh/id_rsa -v $SSH_AUTH_SOCK:/run/ssh_agent -e SSH_AUTH_SOCK=/run/ssh_agent -v "$PWD"/django-project:/root/django-project -v "$PWD"/django-apps:/root/django-apps --env PROJECT_NAME=django-project --env SETTINGS_MODULE=locals3 --env POSTGRES_USER=user1 --env POSTGRES_PASSWORD=user_secret --env POSTGRES_DB=db1 --env POSTGRES_HOST=db1 --env REDIS_HOST=redis1 --env REDIS_PORT=6379 -p 33333:8000 --name=app1 alexisbellido/django:1.11 production

If you want to run some tests in the container, you can pass a parameter not considered by the entrypoint script, like /bin/bash and you will get to a Bash command line. Note the ``-it`` option to run an interactive process in the foreground. This is useful to test Python packages.

.. code-block:: bash

    $ docker run -it --network=project_network -w /root -v ~/.ssh/id_rsa:/root/.ssh/id_rsa -v $SSH_AUTH_SOCK:/run/ssh_agent -e SSH_AUTH_SOCK=/run/ssh_agent -v "$PWD"/django-project:/root/django-project -v "$PWD"/django-apps:/root/django-apps --env PROJECT_NAME=django-project --env SETTINGS_MODULE=local --env POSTGRES_USER=user1 --env POSTGRES_PASSWORD=user_secret --env POSTGRES_DB=db1 --env POSTGRES_HOST=db1 -p 33332:8000 --name=app1-test alexisbellido/django:1.11 /bin/bash

Because it's running in the foreground, if you exit this container it will stop. Remember that each Docker container needs to focus on keeping one service running. Start it and ssh into it again running:

.. code-block:: bash

  $ docker start app1-test
  $ docker exec -it app1-test /bin/bash

You can create a new virtual environment with:

.. code-block:: bash

  $ /usr/local/bin/python3.6 -m venv /root/.venv/my-project

and activate it with:

.. code-block:: bash

    $ source /root/.venv/my-project/bin/activate

You can deactivate a Python virtual environment running:

.. code-block:: bash

    $ deactivate

Note that deactivate is created when sourcing the activate script so it may not be available from the shell when you first ssh into the container. Read more about `venv <https://docs.python.org/3/library/venv.html>`_.

To bypass the entrypoint script, use ``--entrypoint``. This also uses ``-it`` and adds ``--rm`` to remove the container automatically after it stops.

.. code-block:: bash

  $ docker run -it --rm --network=project_network -w /root -v ~/.ssh/id_rsa:/root/.ssh/id_rsa -v $SSH_AUTH_SOCK:/run/ssh_agent -e SSH_AUTH_SOCK=/run/ssh_agent -v "$PWD"/django-project:/root/django-project -v "$PWD"/django-apps:/root/django-apps --env PROJECT_NAME=django-project --env SETTINGS_MODULE=locals3 --env POSTGRES_USER=user1 --env POSTGRES_PASSWORD=user_secret --env POSTGRES_DB=db1 --env POSTGRES_HOST=db1 -p 33332:8000 --name=app1-dev --entrypoint /bin/bash alexisbellido/django:1.11

Note the environment variables:

- ``SETTINGS_MODULE``, used for ``DJANGO_SETTINGS_MODULE``
- ``PROJECT_NAME``, the name of your project
- ``PORT``

Build the image from the directory that contains the corresponding Dockerfile, login to Docker Hub and push the image with:

.. code-block:: bash

  $ docker build -t alexisbellido/django:1.11 .
  $ docker login
  $ docker push alexisbellido/django:1.11

Check logs of running container (-f works like in tail) to confirm it's working as expected:

.. code-block:: bash

  $ docker logs -f CONTAINER

There's `a bug <https://github.com/docker/for-mac/issues/307>`_ that causes Docker not to follow the logs making it difficult to see console output and debug using Django's development server or Gunicorn from the Django application. To work around this use Django's logging system. Start by adding this to your settings file:

.. code-block:: bash

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

  import logging
  import pprint
  logger = logging.getLogger(__name__)
  logger.info(pprint.pformat(vars(object)))

See `Django logging documentation <https://docs.djangoproject.com/en/1.11/topics/logging/>`_ for details.

You can run a few Django commands from the container using /usr/local/bin/docker-entrypoint.sh, for example:

.. code-block:: bash

  $ docker exec -it CONTAINER docker-entrypoint.sh collectstatic
  $ docker exec -it CONTAINER docker-entrypoint.sh shell
  $ docker exec -it CONTAINER docker-entrypoint.sh pip freeze
  $ docker exec -it CONTAINER docker-entrypoint.sh dev-test

Note the example passing `pip freeze` as the last parameter uses docker-entrypoint.sh just to activate the Python environment. Also, the full path is optional because it should already be in the default $PATH but I'm still including it in some of the examples for clarity.

The examples with `dev-test` bypasses `pip install` when running the development server.

Or you can ssh into the container, set the environment from the bash script and then run Django commands from there.

.. code-block:: bash

  $ docker exec -it CONTAINER /bin/bash
  $ source /usr/local/bin/docker-entrypoint.sh setenv
  $ django-admin help --pythonpath=$(pwd)

This is another way of activating the default environment (called *django*) on the container.

.. code-block:: bash

  source /root/.venv/django/bin/activate

You can modify docker-entrypoint.sh script as needed. It already contains the environment variables used by the Django project.

Make sure to check for ALLOWED_HOSTS issues in the Django settings file:

  ``ALLOWED_HOSTS = ['*']``

Nginx
------------------------------------------

Nginx proxying to Gunicorn (final part of volume mapping directory, /usr/share/nginx/project, matches PROJECT_NAME).

The Django project, as created by django-admin startproject, is in a directory with this structure:

.. code-block:: bash

  - project (this is /path/to/outer/project, just a container for the project)
    -- django-app-1
    -- django-app-2
    -- manage.py
    -- media
    -- project (inner directory, actual Python package to import anything inside project)
    -- static

Note django-app-1 and django-app-2 could be siblings of manage.py or be installed via pip so that they are in Python's module search path. The directories media and static should be used by Nginx to serve assets.

# TODO Python code should be included in Django (app) image, should media and static be part of Nginx (web) image? Probably need a way to have a shared filesystem for those. Mapped host volumes for development and NFS, EFS or similar on production. What about Kubernetes volumes?

Build the image from the directory that contains the Nginx Dockerfile.

.. code-block:: bash

  $ docker build -t alexisbellido/nginx:1.14.0 .

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

  $ docker run -d --network=project_network --mount source=media,target=/usr/share/nginx/project/media --mount source=static,target=/usr/share/nginx/project/static --env APP_HOST=app1 -p 33334:80 --name=web1 alexisbellido/nginx:1.14.0

If you have media and static inside the project directory you could bind mount the project directory but you lose the benefits of using Docker volumes.

.. code-block:: bash

  $ docker run -d --network=project_network --mount source=/path/to/outer/project,target=/root/project --env APP_HOST=app1 -p 33334:80 --name=web1 alexisbellido/nginx:1.14.0

Experiment with configuration using test.conf. The following assumes test.conf is in the current directory ($PWD) but it could be anywhere on the host.

.. code-block:: bash

  $ docker run -d --network=project_network --mount type=bind,source=$PWD/test.conf,target=/etc/nginx/conf.d/default.conf --mount source=media,target=/usr/share/nginx/project/media --mount source=static,target=/usr/share/nginx/project/static --env APP_HOST=app1 -p 33334:80 --name=web1 alexisbellido/nginx:1.14.0

Now make changes in test.conf in host and reload Nginx in container.

.. code-block:: bash

  $ docker exec -it web1 /etc/init.d/nginx reload

Tail project's error log.

.. code-block:: bash

  $ docker exec -it web1 tail -f /var/log/nginx/project-error.log

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

  $ docker run -d --network=project_network -p 33345:83 --env WEB_HOST=web1 --env WEB_PORT=80 --env DOMAIN_NAME=example.com --name=cache1 alexisbellido/varnish:4.1

To pass parameters to modify the included VCL and redirect to SSL and www version:

.. code-block:: bash

  $ docker run -d --network=project_network -p 33355:83 --env WEB_HOST=web1 --env WEB_PORT=80 --env DOMAIN_NAME=example.com --env SSL_WWW_REDIRECT=1 --name=cache1-ssl alexisbellido/varnish:4.1

To map an existing VCL file:

.. code-block:: bash

  $ docker run -d --network=project_network -v /home/alexis/mydocker/dockerize-django/varnish/default-test.vcl:/etc/varnish/default.vcl -p 33335:83 --env WEB_HOST=web1 --env WEB_PORT=80 --env DOMAIN_NAME=example.com --name=cache-map-1 alexisbellido/varnish:4.1

Django needs to allow Nginx or Varnish's probe won't work. Include this in your Django settings:

  ``ALLOWED_HOSTS = ['*']``

Of course, you can provide the hostname for Nginx.
Use curl from the Varnish container to the Nginx container to debug.

Build the image from the directory contains the corresponding Dockerfile, with:

.. code-block:: bash

  $ docker build -t alexisbellido/varnish:4.1 .


HAProxy
------------------------------------------

haproxy non-ssl:

.. code-block:: bash

  $ docker run -d --network zinibu -v /home/alexis/mydocker/dockerize-django/haproxy/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg -p 35004:8998 -p 35005:80 -p 35006:443 --name=lb alexisbellido/haproxy:1.6.10

Default HAProxy stats at http://example.com:35004/admin?stats (user: admin, password: admin)

haproxy ssl:

.. code-block:: bash

  $ docker run -d --network zinibu -v /home/alexis/mydocker/ssl/example_com.pem:/usr/local/etc/haproxy/ssl/example_com.pem -v /home/alexis/mydocker/dockerize-django/haproxy/haproxy-ssl.cfg:/usr/local/etc/haproxy/haproxy.cfg -p 35104:8998 -p 35105:80 -p 35106:443 --name=lb-ssl alexisbellido/haproxy:1.6.10

Default HAProxy stats at http://example.com:35104/admin?stats  (user: admin, password: admin)

haproxy.cfg copied in Dockerfile is overriden when running via bind mount.

Build the image from the haproxy directory, which contains the corresponding Dockerfile, with:

.. code-block:: bash

  $ docker build -t alexisbellido/haproxy:1.6.10 .


Ansible
------------------------------------------

Some Ansible examples that assume you are running as root, the control machine has its public key on the remote machines' ``~/.ssh/authorized_keys``, and the remote machines have ssh authentication setup for GitHub and any other remote server used.

.. code-block:: bash

   $ pip install ansible

Running git clone from GitHub.

.. code-block:: bash

  $ ansible all -m git -a "repo=git@github.com:alexisbellido/django-zinibu-skeleton.git dest=/root/django-apps/django-zinibu-skeleton version=master accept_hostkey=yes"


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
