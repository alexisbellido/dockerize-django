FROM python:3.6.5-stretch

LABEL maintainer="Alexis Bellido <a@zinibu.com>"

COPY requirements.txt /root/requirements.txt
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
WORKDIR /root

# Install requisites for building Python packages.
# I need to avoid error messages from pip freeze.
RUN set -x \
  && apt-get -y update \
  && apt-get install -y unixodbc-dev

# TODO create venv and use it for running Python script in container
# TODO use SHELL or exec form of RUN
RUN /bin/bash -c "pip install --upgrade pip && pip install --no-cache-dir -r requirements.txt"

# how to pass python example.py to ENTRYPOINT and run in venv?
# see SO bookmarked and try $@
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

# TODO CMD part, try passing default arguments to opython script here
#CMD ["building"]
