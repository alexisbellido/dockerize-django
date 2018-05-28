Django Project
========================================

Just the basics to launch a Docker-based Django project with Gunicorn for production and Django runserver for development.

No need for `gosu <https://github.com/tianon/gosu>`_ because there's no need to step down from the root user during container startup, specifically in the *ENTRYPOINT*.


Use multi-stage build passing an ssh private key to access any private repositories, either via git or pip. See Dockerfile.

.. code-block:: bash

  $ docker build --build-arg SSH_PRIVATE_KEY="$(cat ~/.ssh/id_rsa)" -t alexisbellido/django:2.0.5 .

These commands run bind mount the Django project from the same directory where the Dockerfile for Django is so that $PWD/project, which can also be expressed as "$(pwd)"/project, is the outer project directory mapped to /root/project in the container. This is useful for changing code during development but at the end the project code should be part of the image.

.. code-block:: bash
  $ docker run -it --rm --mount type=bind,source="$(pwd)"/project,target=/root/project -p 8000:8000 alexisbellido/django:2.0.5 /bin/bash

This uses the absolute path to the project.

.. code-block:: bash

  $ docker run -it --rm --mount type=bind,source=/path/to/outer/project,target=/root/project -p 8000:8000 alexisbellido/django:2.0.5 /bin/bash

If you mount a bind mount or non-empty volume into a directory in the container in which some files or directories exist, these files or directories are obscured by the mount. Read more about `volumes and bind mounts <https://docs.docker.com/storage/#good-use-cases-for-volumes>`_.

Run development server in foreground mode with support for interactive processes (-it) and removal on exit (--rm).

.. code-block:: bash

  $ docker run -it --rm -p 8000:8000 alexisbellido/django:2.0.5 development

Note development and production are using media and static volumes, the same that Nginx uses on the host. This is important for Django collectstatic.

Run development server in detached mode on a bridge network and mapping project directory for development. Once development is done it will be enough with source code included in the image.

.. code-block:: bash

  $ docker run -d --network=project_network --mount type=bind,source=/path/to/outer/project,target=/root/project --mount source=media,target=/root/project/media --mount source=static,target=/root/project/static --name=app1 -p 8000:8000 alexisbellido/django:2.0.5 development

Run production in detached mode.

.. code-block:: bash

  $ docker run -d --network=project_network --mount source=media,target=/root/project/media --mount source=static,target=/root/project/static --name=app1 -p 8000:8000 alexisbellido/django:2.0.5 production

Execute commands on running container. Use docker-entrypoint.sh to activate Python environment and set environment for Django. 

.. code-block:: bash

  $ docker exec -it app1 /usr/local/bin/docker-entrypoint.sh pip freeze
  $ docker exec -it app1 /usr/local/bin/docker-entrypoint.sh django-admin help
  $ docker exec -it app1 /usr/local/bin/docker-entrypoint.sh django-admin collectstatic
  
  
