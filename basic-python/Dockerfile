FROM python:3.6.5-stretch
MAINTAINER Alexis Bellido <a@zinibu.com>

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
RUN /bin/bash -c "pip install --upgrade pip && pip install --no-cache-dir -r requirements.txt"

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

# TODO CMD part
#CMD ["building"]
