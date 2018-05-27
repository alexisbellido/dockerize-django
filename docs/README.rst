Django Project
========================================

Just the basics to launch a Docker-based Django project with Gunicorn for production and Django runserver for development.

No need for `gosu <https://github.com/tianon/gosu>`_ because there's no need to step down from the root user during container startup, specifically in the *ENTRYPOINT*.

These commands run from the directory where the Dockerfile for Django is so that $PWD/project, which can also be expressed as "$(pwd)"/project, is the outer project directory mapped to /root/project in the container.

.. code-block:: bash

  $ docker build --build-arg SSH_PRIVATE_KEY="$(cat ~/.ssh/id_rsa)" -t alexisbellido/django:2.0.5 .
  $ docker run -it --rm --mount type=bind,source="$(pwd)"/project,target=/root/project -p 8000:8000 alexisbellido/django:2.0.5 /bin/bash

This uses the absolute path to the project.

.. code-block:: bash

  $ docker run -it --rm --mount type=bind,source=/path/to/outer/project,target=/root/project -p 8000:8000 alexisbellido/django:2.0.5 /bin/bash

If you mount a bind mount or non-empty volume into a directory in the container in which some files or directories exist, these files or directories are obscured by the mount. Read more about `volumes and bind mounts <https://docs.docker.com/storage/#good-use-cases-for-volumes>`_.

Use this for changing code during development.

Run development server in foreground mode with support for interactive processes (-it) and removal on exit (--rm).

.. code-block:: bash

  $ docker run -it --rm -p 8000:8000 alexisbellido/django:2.0.5 development

Run development server in detached mode on a bridge network and mapping project directory for development. Once development is done it will be enough with source code included in the image.

.. code-block:: bash

  $ docker run -d --network=project_network --mount type=bind,source=/path/to/outer/project,target=/root/project --name=app1 -p 8000:8000 alexisbellido/django:2.0.5 development

Run production in detached mode.

.. code-block:: bash

  $ docker run -d --network=project_network --name=app1 -p 8000:8000 alexisbellido/django:2.0.5 production

Any other commands.

.. code-block:: bash

  $ docker run -it --rm -p 8000:8000 alexisbellido/django:2.0.5 django-admin help

Execute command on running container

.. code-block:: bash

  $ docker exec -it container-name command
