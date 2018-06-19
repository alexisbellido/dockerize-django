Set correct terminal size for container

.. code-block:: bash

  $ docker exec -e COLUMNS="`tput cols`" -e LINES="`tput lines`" -ti container bash

