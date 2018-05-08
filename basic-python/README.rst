Python and Click
========================================

A Python container using `Click <http://click.pocoo.org/5/>`_ for a basic client-based command.

Dockerfile and docker-entrypoint.sh follow standard practices to activate the Python virtual environment and allow passing arguments to Python script running in the container.

Note the use of --no-cache to simplify testing when building the image. That should be removed when building the final image to push.

.. code-block:: bash

$ docker build --no-cache -t alexisbellido/test:0.1 .
$ docker run -it --rm -v $PWD:/root alexisbellido/test:0.1 python example.py --input accession-numbers

$ docker build --no-cache --target builder --build-arg SSH_PRIVATE_KEY="$(cat ~/.ssh/id_rsa)" -t alexisbellido/test:0.2 .

TODO
--------------------------------------------------

ssh -T git@github.com

git clone https://github.com/cooperhewitt/py-cooperhewitt-swatchbook

pip install -e git://github.com/celery/django-celery.git#egg=django-celery
pip install -e git://github.com/username/app-nam  e.git#egg=app-name
