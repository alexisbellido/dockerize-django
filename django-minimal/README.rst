Minimal Django Project
========================================

Just the basics to launch a Docker-based Django project with Gunicorn for production and Django runserver for development.

No need for `gosu <https://github.com/tianon/gosu>`_ because there's no need to step down from the root user during container startup, specifically in the *ENTRYPOINT*.

These commands run from directory where the Dockerfile for django-minimal is so that $PWD/project is the Django project directory mapped to /root/project in the container.

.. code-block:: bash

  $ docker build --build-arg SSH_PRIVATE_KEY="$(cat ~/.ssh/id_rsa)" -t alexisbellido/django-minimal:0.1 .
  $ docker run -it --rm -v $PWD/project:/root/project -w /root/project -p 8000:8000 alexisbellido/django-minimal:0.1 /bin/bash

When mounting volume with docker run the mount hides corresponding directory on container. Use for changing code on development.

Run development server in foreground mode with support for interactive processes (-it) and removal on exit (--rm).

.. code-block:: bash

  $ docker run -it --rm -p 8000:8000 alexisbellido/django-minimal:0.1 development

Run production in detached mode.

.. code-block:: bash

  $ docker run -d -p 8000:8000 alexisbellido/django-minimal:0.1 production 
  
Any other commands.

.. code-block:: bash

  $ docker run -it --rm -p 8000:8000 alexisbellido/django-minimal:0.1 django-admin help
  
Execute command on running container

.. code-block:: bash

  $ docker exec -it container-name command

TODO
========================================

Modify entrypoint to run production with Gunicorn with an Nginx container.

Yes, try different settings per Django environment and use environment variables from Docker Compose. Try to make minimal changes to Django project code. Mount volume when running to try changing Django project code.

docker run -d 
 
PostgreSQL basics.

