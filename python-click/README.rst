Python and Click
========================================

A Python container using `Click <http://click.pocoo.org/5/>`_ for a basic client-based command.

Dockerfile and docker-entrypoint.sh follow standard practices to activate the Python virtual environment and allow passing arguments to Python script running in the container. Mounts current directory in /root directory of container.

.. code-block:: bash

  $ docker build -t alexisbellido/test:0.1 .
  $ docker run -it --rm -v $PWD:/root alexisbellido/test:0.1 python example.py --input accession-numbers

Also see `<https://github.com/alexisbellido/znbpackage>`_.

Access a service running on the host from the container
------------------------------------------------------------------------

Run container using --network host to access a MySQL instance running on host. This instance could be another container exposing port 3306 to the host.

.. code-block:: bash

  $ docker run -it --rm --network host -v $PWD:/root/Projects alexisbellido/color-process:0.1 /bin/bash

and then container can access MySQL from the host using 127.0.0.1. For some reason the name localhost won't work.

.. code-block:: bash

  # mysql -u root -h 127.0.0.1 collection

TODO
--------------------------------------------------
