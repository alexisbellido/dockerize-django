Node, React, Webpack and Other Javascript Stuff
======================================================================================

Use a small Docker image.

.. code-block:: bash

  $ docker run -it --rm node:10.11-alpine /bin/ash
  $ docker run -it --rm node:10.11-alpine node -v

I can run a temporary NodeJS container that mounts a volume from a running service, the one used by Nginx in a running Docker Swarm service, and run npm commands inside that container. It doesn't have to be a part of the service and will be removed (--rm) after its job it's done.

.. code-block:: bash

  # Get names of existing volumes. For this example choose service-name_static.
  $ docker volume ls
  $ docker run -it --rm --mount type=volume,source=service-name_static,target=/root/project/static -w /root/project/static node:10.11-alpine /bin/ash
  $ docker run -it --rm --mount type=volume,source=service-name_static,target=/root/project/static -w /root/project/static node:10.11-alpine npm help

TODO

for development the web service, which is Nginx, could use type bind instead of volume, so from 

- type: volume
  source: static
  target: /usr/share/nginx/public/static

to something like

- type: bind
  source: ../django/project/static
  target: /usr/share/nginx/public/static

and then

.. code-block:: bash

  $ docker run -it --rm --mount type=bind,source=/path/to/static/on/host,target=/root/project/static -w /root/project/static node:10.11-alpine npm run watch

once the code is built a new image can be created and used for production
also, once web service is used with a volume instead of a bind the code from static could copied with docker cp from host to container, hence to the volume 
but at the end everything should be in the image and that should be used on production