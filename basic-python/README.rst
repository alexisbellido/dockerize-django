Python and Click
========================================

A Python container using `Click <http://click.pocoo.org/5/>`_ for a basic client-based command.

Dockerfile and docker-entrypoint.sh follow standard practices to activate the Python virtual environment and allow passing arguments to Python script running in the container. Mounts current directory in /root directory of container.

.. code-block:: bash

  $ docker build -t alexisbellido/test:0.1 .
  $ docker run -it --rm -v $PWD:/root alexisbellido/test:0.1 python example.py --input accession-numbers

Also see `<https://github.com/alexisbellido/znbpackage>`_.

Use multi-stage builds
--------------------------------------------------

This allows passing a local ssh private key to an intermediate image, a build stage,
and then using that to clone private repositories, either via git clone or pip -e.

Note that that ssh and git clients are needed to clone over git+ssh so they are
both installed in the intermediate build stage.

See `Docker multi-stage builds <https://docs.docker.com/develop/develop-images/multistage-build/>`_.

Stop at a specific build stage. Note the use of --no-cache to simplify testing.

.. code-block:: bash

  $ docker build --no-cache --target builder --build-arg SSH_PRIVATE_KEY="$(cat ~/.ssh/id_rsa)" -t alexisbellido/test:0.2 .
  $ docker run -it --rm alexisbellido/test:0.2 /bin/bash

Run until final stage, which won't have SSH_PRIVATE_KEY information.

.. code-block:: bash

  $ docker build --build-arg SSH_PRIVATE_KEY="$(cat ~/.ssh/id_rsa)" -t alexisbellido/test:0.2 .
  $ docker run -it --rm alexisbellido/test:0.2 /bin/bash

Installing with pip from private VCS's
--------------------------------------------------

.. code-block:: bash

  $ pip install -e git+ssh://user@example.com:/home/user/git/app-name.git#egg=app-name
  $ pip install -e git://github.com/celery/django-celery.git#egg=django-celery
  $ pip install -e git://github.com/username/app-nam  e.git#egg=app-name

TODO
--------------------------------------------------
