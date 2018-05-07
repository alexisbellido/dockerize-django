Python and Click
========================================

A Python container using `Click <http://click.pocoo.org/5/>`_ for a basic client-based command.

Dockerfile and docker-entrypoint.sh follow standard practices to activate the Python virtual environment and allow passing arguments to Python script running in the container.

Note the use of --no-cache to simplify testing when building the image. That should be removed when building the final image to push.

.. code-block:: bash

$ docker build --no-cache -t alexisbellido/test:0.1 .
$ docker run -it --rm -v $PWD:/root alexisbellido/test:0.1 python example.py --input accession-numbers

TODO
--------------------------------------------------
