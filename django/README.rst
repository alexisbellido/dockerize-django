Django Project
========================================

Just the basics to launch a Docker-based Django project with Gunicorn for production and Django runserver for development.

No need for `gosu <https://github.com/tianon/gosu>`_ because there's no need to step down from the root user during container startup, specifically in the *ENTRYPOINT*.

These build command runs from the directory where the Dockerfile for Django is so that $PWD/project is the outer project directory mapped to /root/project in the container.

.. code-block:: bash

  $ docker build --build-arg SSH_PRIVATE_KEY="$(cat ~/.ssh/id_rsa)" -t alexisbellido/django:2.0.5 .
  $ docker run -it --rm -v /path/to/outer/project:/root/project -w /root/project -p 8000:8000 alexisbellido/django:2.0.5 /bin/bash

When mounting volume (-v) the /root/project copied from the image is hidden in the container. Use this for changing code during development.

Run development server in foreground mode with support for interactive processes (-it) and removal on exit (--rm).

.. code-block:: bash

  $ docker run -it --rm -p 8000:8000 alexisbellido/django:2.0.5 development
  
Run development server in detached mode on a bridge network and mapping project directory for development.

.. code-block:: bash
  
  $ docker run -d --network=project_network -v /path/to/outer/project:/root/project --name=app1 -p 8000:8000 alexisbellido/django:2.0.5 development

Run production in detached mode.

.. code-block:: bash

  $ docker run -d --network=project_network --name=app1 -p 8000:8000 alexisbellido/django:2.0.5 production 
  
Any other commands.

.. code-block:: bash

  $ docker run -it --rm -p 8000:8000 alexisbellido/django:2.0.5 django-admin help
  
Execute command on running container

.. code-block:: bash

  $ docker exec -it container-name command

TODO
========================================

Use updated Nginx conf from Gunicorn docs.

At some point push basics to Docker Hub and create docker-compose.yml to set up everything.

Modify entrypoint to run production with Gunicorn with an Nginx container.

Rebuild images for django and nginx.

Yes, try different settings per Django environment and use environment variables from Docker Compose. Try to make minimal changes to Django project code. Mount volume when running to try changing Django project code.

docker run -d 
 
PostgreSQL basics.

Move docs specific to the full stack to main README and leave specifics for this image here.