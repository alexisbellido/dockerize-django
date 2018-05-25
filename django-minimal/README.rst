Minimal Django Project
========================================

Just the basics to launch a Docker-based Django project with Gunicorn for production and Django runserver for development.

No need for `gosu <https://github.com/tianon/gosu>`_ because there's no need to step down from the root user during container startup, specifically in the *ENTRYPOINT*.

These commands run from directory where the Dockerfile for django-minimal is so that $PWD/project is the Django project directory mapped to /root/project in the container.

.. code-block:: bash

  $ docker build --build-arg SSH_PRIVATE_KEY="$(cat ~/.ssh/id_rsa)" -t alexisbellido/django-minimal:0.1 .
  $ docker run -it --rm -v $PWD/project:/root/project -w /root/project -p 8000:8000 alexisbellido/django-minimal:0.1 /bin/bash

When mounting volume with docker run the mount hides corresponding directory on container. Use for changing code on development.

TODO
========================================

Run dev server and expose port to see basic Django page. No settings changed yet.
# django-admin runserver --pythonpath=$(pwd) --settings=project.settings 0.0.0.0:8000

Modify entrypoint to run development server.

Modify entrypoint to run production with Gunicorn and connect with an Nginx container.


.. code-block:: bash

  root@3bf8ea214201:~/project# pwd
  /root/project
  root@3bf8ea214201:~/project# django-admin shell --pythonpath=$(pwd) --settings=project.settings
  Python 3.6.5 (default, May  5 2018, 03:07:21) 
  [GCC 6.3.0 20170516] on linux
  Type "help", "copyright", "credits" or "license" for more information.
  (InteractiveConsole)
  >>> import django
  >>> django.VERSION
  (2, 0, 5, 'final', 0)

