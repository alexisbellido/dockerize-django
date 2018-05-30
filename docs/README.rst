Django Project
========================================

Just the basics to launch a Docker-based Django project with Gunicorn for production and Django runserver for development.

No need for `gosu <https://github.com/tianon/gosu>`_ because there's no need to step down from the root user during container startup, specifically in the *ENTRYPOINT*.

Use multi-stage build passing an ssh private key to access any private repositories, either via git or pip. See Dockerfile.

.. code-block:: bash

  $ docker build --build-arg SSH_PRIVATE_KEY="$(cat ~/.ssh/id_rsa)" -t username/django:2.0.5 .

Once you've built the image you can push it to Docker hub.

.. code-block:: bash

  $ docker login
  $ docker push username/django:2.0.5

These commands run bind mount the Django project from the same directory where the Dockerfile for Django is so that $PWD/project, which can also be expressed as "$(pwd)"/project, is the outer project directory mapped to /root/project in the container. This is useful for changing code during development but at the end the project code should be part of the image.

.. code-block:: bash
  $ docker run -it --rm --mount type=bind,source="$(pwd)"/project,target=/root/project -p 8000:8000 username/django:2.0.5 /bin/bash

This uses the absolute path to the project.

.. code-block:: bash

  $ docker run -it --rm --mount type=bind,source=/path/to/outer/project,target=/root/project -p 8000:8000 username/django:2.0.5 /bin/bash

If you mount a bind mount or non-empty volume into a directory in the container in which some files or directories exist, these files or directories are obscured by the mount. Read more about `volumes and bind mounts <https://docs.docker.com/storage/#good-use-cases-for-volumes>`_.

Run development server in foreground mode with support for interactive processes (-it) and removal on exit (--rm).

.. code-block:: bash

  $ docker run -it --rm -p 8000:8000 username/django:2.0.5 development

Note development and production are using media and static volumes, the same that Nginx uses on the host. This is important for Django collectstatic.

Run development server in detached mode on a bridge network and mapping project directory for development. Once development is done it will be enough with source code included in the image.

.. code-block:: bash

  $ docker run -d --network=project_network --mount type=bind,source=/path/to/outer/project,target=/root/project --mount source=media,target=/root/project/media --mount source=static,target=/root/project/static --env POSTGRES_USER=user1 --env POSTGRES_PASSWORD=user_secret --env POSTGRES_DB=db1 --env POSTGRES_HOST=dbserver1 --name=app1 -p 8000:8000 username/django:2.0.5 development

If you are in the same directory as the Django Dockerfile you can use $PWD/project instead for /path/to/outer/project.

.. code-block:: bash

  $ docker run -d --network=project_network --mount type=bind,source=$PWD/project,target=/root/project --mount source=media,target=/root/project/media --mount source=static,target=/root/project/static --env POSTGRES_USER=user1 --env POSTGRES_PASSWORD=user_secret --env POSTGRES_DB=db1 --env POSTGRES_HOST=dbserver1 --name=app1 -p 8000:8000 username/django:2.0.5 development

Run production in detached mode.

.. code-block:: bash

  $ docker run -d --network=project_network --mount source=media,target=/root/project/media --mount source=static,target=/root/project/static --env POSTGRES_USER=user1 --env POSTGRES_PASSWORD=user_secret --env POSTGRES_DB=db1 --env POSTGRES_HOST=dbserver1 --name=app1 -p 8000:8000 username/django:2.0.5 production

If you pass any parameter not considered by the entrypoint script (docker-entrypoint.sh), it will be just executed with exec "$@".

Execute commands on running container. Use docker-entrypoint.sh to activate Python environment and set environment for Django.

.. code-block:: bash

  $ docker exec -it app1 /usr/local/bin/docker-entrypoint.sh pip freeze
  $ docker exec -it app1 docker-entrypoint.sh django-admin help
  $ docker exec -it app1 docker-entrypoint.sh django-admin collectstatic

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

https://docs.python.org/3/using/cmdline.html#envvar-PYTHONUNBUFFERED and environment variable PYTHONUNBUFFERED set to 1 may be solution to use docker logs with print in some cases but more control with logging.

You may need to change ALLOWED_HOSTS in the Django settings file.

  ``ALLOWED_HOSTS = ['*']``
