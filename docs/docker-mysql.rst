Docker and MySQL
==========================================================

Execute mysql client inside a running container. Note environment variables to use full width.

.. code-block:: bash

  docker exec -i -e COLUMNS="`tput cols`" -e LINES="`tput lines`" CONTAINER mysql -u root -h 192.168.1.183


Run a container to use its mysql client. It could connect to other host.

.. code-block:: bash

  docker run -it --rm mysql:5.5.60 mysql -u root -h 192.168.1.183