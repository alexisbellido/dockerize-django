Node, React, webpack and Other Javascript Stuff
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

===

Sending webpack's bundle directly to Django's static directory

See the znbmain directory, which is based on a Django application directory (the one containing apps.py, models.py and so on) for sample webpack files structure. This is for an older version of webpack but the ideas apply to other version.

There's a build script in package.json that passes a NODE_ENV environment variable to webpack.

.. code-block:: bash

  "build": "NODE_ENV=production webpack --config client/config/webpack.config.js -p",

and client/config/webpack.config.js uses it to build for either prodution or development.

There's also a watch script in package.json that can be called with a DJANGO_STATIC_PATH environment variable to set the buildPath for webpack.

.. code-block:: bash

  $ DJANGO_STATIC_PATH=/full-path-to-project/static/znbmain npm run watch

This can be build and send the files directly to the Django project's static directory during development. For production it should be all right to just build to the app's static directory and let collectstatic move everything to the project.

With Docker this would be something like the following (verify path to mount).

.. code-block:: bash

  $ docker run -it --rm --mount type=bind,source=/path/to/static/on/host,target=/root/project/static -w /root/project/static -e DJANGO_STATIC_PATH=/full-path-to/static/znbmain node:10.11-alpine npm run watch

Review how collectstatic should be run to move files from application directory to project static directory.

This does not prompt user for input and ignores the admin path.

.. code-block:: bash

  $ docker exec -it CONTAINER_ID docker-entrypoint.sh django-admin.py collectstatic --noinput -i admin

I think it would be easier if the webpack build would be provided by just one Django application but I suppose more than on app could build their own files if that makes sense.