Minimal Django Project
========================================

Just the basics to launch a Docker-based Django project with Gunicorn for production and Django runserver for development.

No need for `gosu <https://github.com/tianon/gosu>`_ because there's no need to step down from the root user during container startup, specifically in the *ENTRYPOINT*.