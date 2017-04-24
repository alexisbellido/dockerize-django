Docker images to build a Django project
==========================================

A Django stack running with Docker.


Overview
------------------------------------------

* Create a directory for your project and clone this repository inside it.
* Clone your Django project in the project directory and call it *django-project".
* Create another directory containing your custom Django applications and call it *django-apps*.

Your directory structure should look like this:

.. code-block:: bash

  - project
    -- dockerize-django (this repository)
    -- django-project
    -- django-apps
      ---- django-awesome-app
      ---- django--tiny-app

Most Docker commands here should be run from the project directory and will refer to it as "$PWD".

If running locally for development, it uses one HAProxy container to load balance containers running Varnish that cache Nginx in front Gunicorn. Usually just one Docker host takes care of all containers.

If running on AWS, it uses ELB to load balance containers running Varnish that cache Nginx in front Gunicorn. The default setup assumes three containers running on each Docker host: Varnish, Nginx and Gunicorn.

My Docker Hub user is *alexisbellido* and I'm calling my network *project-network*:

Create a bridge network for your containers on your host.

.. code-block:: bash

  $ docker network create -d bridge project-network


The examples below assume a basic architecture like this:

lb --> cache1 --> web1 --> app1

lb: load balancer, optional HAProxy for local development.
cache1: Varnish. There are alternative versions with SSL or mapping a VCL file.
web1: Nginx.
app1: Django application running on Gunicorn.


PostgreSQL
------------------------------------------

Run the container passing parameters.

.. code-block:: bash

  $ docker run -d --network=project-network --env POSTGRES_USER=user1 --env POSTGRES_PASSWORD=user_secret --env POSTGRES_DB=db1 --hostname=db1 --name=db1 postgres:9.4

Access psql:

.. code-block:: bash

  $ docker exec -it db1 psql -h db1 -U user1 -d db1

To restore from a dump created with just psql:

.. code-block:: bash

  $ docker exec -it db1 psql -h db1 -U user1 -d db1 -f /tmp/db1.sql

Create compressed database dump from the container (note this is saving to /tmp just as an example, you should use a non-public location):

.. code-block:: bash

  $ docker exec -it db2 /bin/bash``
  $ pg_dump -Fc -v -h db2 -U user2 db2 > /tmp/db2-$(date +"%m%d%Y-%H%M%S").dump

Create compressed database dump from AWS RDS:

.. code-block:: bash

  $ pg_dump -Fc -v -h somehostname.us-east-1.rds.amazonaws.com -U user dbname > dbname.dump

Copy a database dump from a container (db2) to the current directory on the host:

.. code-block:: bash

  $ docker cp db2:/tmp/dbname.dump .

Use docker cp to copy a database dump, created with pg_dump, and restore it to a container.

.. code-block:: bash

  $ docker cp /home/user/backup/dbname.dump db1:/tmp/dbname.dump

Restore using -c to drop database objects before recreating them.  You may need to ssh into the container before you can restore with pg_restore:

.. code-block:: bash

  $ docker exec -it db2 /bin/bash
  $ pg_restore -v -c -h db2 -U user2 -d db2 /tmp/dbname.dump


You can also use Docker Compose to launch all the containers for your stack at once.::

.. code-block:: bash

    $ cd compose-complete
    $ docker-compose up

This connects to a container creater with Docker Compose and doesn't need to ssh first:

.. code-block:: bash

  $ docker-compose exec db1 pg_restore -v -c -h db1 -U user1 -d db1 /tmp/dbname.dump

Don't forget to delete the temporary database by logging in to the container and deleting it from bash.

.. code-block:: bash

  $ docker exec -it db1 /bin/bash


Redis
------------------------------------------

.. code-block:: bash

  $ docker run -d --network=project-network --hostname=redis1 --name=redis1 redis:3.2.6

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

Run a Django development server:


.. code-block:: bash

  $ docker run -d --network=project-network -w /root -v ~/.ssh/id_rsa:/root/.ssh/id_rsa -v $SSH_AUTH_SOCK:/run/ssh_agent -e SSH_AUTH_SOCK=/run/ssh_agent -v "$PWD"/django-project:/root/django-project -v "$PWD"/django-apps:/root/django-apps --env PROJECT_NAME=django-project --env SETTINGS_MODULE=locals3 --env POSTGRES_USER=user1 --env POSTGRES_PASSWORD=user_secret --env POSTGRES_DB=db1 --env POSTGRES_HOST=db1 -p 33332:8000 --hostname=app1-dev --name=app1-dev alexisbellido/django:1.11 development

To use Redis pass REDIS_HOST and, for the sake of being implicit, REDIS_PORT:

.. code-block:: bash
   
  $ docker run -d --network=project-network -w /root -v /home/alexis/mydocker/zinibu:/root/zinibu -v /home/alexis/mydocker/djapps:/root/djapps --env PROJECT_NAME=zinibu --env SETTINGS_MODULE=locals3 --env POSTGRES_USER=user1 --env POSTGRES_PASSWORD=user_secret --env POSTGRES_DB=db1 --env POSTGRES_HOST=db1 --env REDIS_HOST=redis1 --env REDIS_PORT=6379 -p 33336:8000 --hostname=app2-dev --name=app2-dev alexisbellido/django:1.11 development

For Django via gunicorn (specifying how to map the port on the host) and using Redis:

.. code-block:: bash

  $ docker run -d --network=project-network -w /root -v /home/alexis/mydocker/zinibu:/root/zinibu -v /home/alexis/mydocker/djapps:/root/djapps --env PROJECT_NAME=zinibu --env SETTINGS_MODULE=locals3 --env POSTGRES_USER=user1 --env POSTGRES_PASSWORD=user_secret --env POSTGRES_DB=db1 --env POSTGRES_HOST=db1 --env REDIS_HOST=redis1 --env REDIS_PORT=6379 -p 33333:8000 --hostname=app1 --name=app1 alexisbellido/django:1.11 production

If you just want to get to the shell for some testing, bypassing the entrypoint script, use ``--entrypoint``. Note the ``-it`` option to run an interactive process in the foreground and ``--rm`` to remove the container automatically after it stops:

.. code-block:: bash

  $ docker run -it --rm --network=project-network -w /root -v ~/.ssh/id_rsa:/root/.ssh/id_rsa -v $SSH_AUTH_SOCK:/run/ssh_agent -e SSH_AUTH_SOCK=/run/ssh_agent -v "$PWD"/django-project:/root/django-project -v "$PWD"/django-apps:/root/django-apps --env PROJECT_NAME=django-project --env SETTINGS_MODULE=locals3 --env POSTGRES_USER=user1 --env POSTGRES_PASSWORD=user_secret --env POSTGRES_DB=db1 --env POSTGRES_HOST=db1 -p 33332:8000 --hostname=app1-dev --name=app1-dev --entrypoint /bin/bash alexisbellido/django:1.11

Note the environment variables:

* ``SETTINGS_MODULE``, used for ``DJANGO_SETTINGS_MODULE``
* ``PROJECT_NAME, the name of your project
* ``PORT``

Build the image from the directory that contains the corresponding Dockerfile, with:

.. code-block:: bash

  $ docker build -t alexisbellido/django:1.11 .


Check logs of running container (-f works like in tail) to confirm it's working as expected:

.. code-block:: bash

  $ docker logs -f CONTAINER

You can run a few Django commands from the container using /usr/local/bin/docker-entrypoint.sh, for example:

.. code-block:: bash

  $ docker exec -it CONTAINER docker-entrypoint.sh collectstatic
  $ docker exec -it CONTAINER docker-entrypoint.sh shell

Or you can ssh into the container, set the environment from the bash script and then run Django commands from there

.. code-block:: bash

  $ docker exec -it CONTAINER /bin/bash
  $ source /usr/local/bin/docker-entrypoint.sh setenv
  $ django-admin help --pythonpath=$(pwd)

You can modify docker-entrypoint.sh script as needed. It already contains the environment variables used by the Django project.

Make sure to check for ALLOWED_HOSTS issues in the Django settings file:

  ``ALLOWED_HOSTS = ['*']``


Nginx
------------------------------------------

Nginx proxying to Gunicorn (final part of volume mapping directory, /usr/share/nginx/zinibu, matches PROJECT_NAME)

.. code-block:: bash

  $ docker run -d --network=project-network -v /home/alexis/mydocker/zinibu:/usr/share/nginx/zinibu --env APP_HOST=app1 --env APP_PORT=8000 --env PROJECT_NAME=zinibu -p 33334:80 --hostname=web1 --name=web1 alexisbellido/nginx:1.10.2

Build the image from the directory that contains the corresponding Dockerfile, with:

.. code-block:: bash

  $ docker build -t alexisbellido/nginx:1.10.2 .


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

  $ docker run -d --network=project-network -p 33345:83 --env WEB_HOST=web1 --env WEB_PORT=80 --env DOMAIN_NAME=example.com --hostname=cache1 --name=cache1 alexisbellido/varnish:4.1

To pass parameters to modify the included VCL and redirect to SSL and www version:

.. code-block:: bash

  $ docker run -d --network=project-network -p 33355:83 --env WEB_HOST=web1 --env WEB_PORT=80 --env DOMAIN_NAME=example.com --env SSL_WWW_REDIRECT=1 --hostname=cache1-ssl --name=cache1-ssl alexisbellido/varnish:4.1

To map an existing VCL file:

.. code-block:: bash

  $ docker run -d --network=project-network -v /home/alexis/mydocker/dockerize-django/varnish/default-test.vcl:/etc/varnish/default.vcl -p 33335:83 --env WEB_HOST=web1 --env WEB_PORT=80 --env DOMAIN_NAME=example.com --hostname=cache-map-1 --name=cache-map-1 alexisbellido/varnish:4.1

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

  $ docker run -d --network zinibu -v /home/alexis/mydocker/dockerize-django/haproxy/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg -p 35004:8998 -p 35005:80 -p 35006:443 --hostname=lb --name=lb alexisbellido/haproxy:1.6.10

Default HAProxy stats at http://example.com:35004/admin?stats (user: admin, password: admin)

haproxy ssl:

.. code-block:: bash

  $ docker run -d --network zinibu -v /home/alexis/mydocker/ssl/example_com.pem:/usr/local/etc/haproxy/ssl/example_com.pem -v /home/alexis/mydocker/dockerize-django/haproxy/haproxy-ssl.cfg:/usr/local/etc/haproxy/haproxy.cfg -p 35104:8998 -p 35105:80 -p 35106:443 --hostname=lb-ssl --name=lb-ssl alexisbellido/haproxy:1.6.10

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

You can inspect the logs of any running container (-f works like in tail) to confirm it's working as expected:

.. code-block:: bash

  $ docker logs -f CONTAINER

SSH into a container to take a closer look:

.. code-block:: bash

  $ docker exec -it CONTAINER /bin/bash

Find out details about run command used to start a container:

.. code-block:: bash

  $ docker inspect -f '{{.Config.Entrypoint}} {{.Config.Cmd}}' CONTAINER
  $ docker inspect -f '{{.Config.Env}}' CONTAINER

And to inspect everything about the container:

.. code-block:: bash

  $ docker inspect CONTAINER | less


Troubleshooting
------------------------------------------

  * When forwarding ssh agent into the container, make sure that the private key file from the host is the one loaded by ssh-agent. You may need to use ``ssh-add`` to list, delete and/or re-add identities (private keys).
