FROM python:3.6.1-slim
MAINTAINER Alexis Bellido <a@zinibu.com>

# With some ideas borrowed from https://hub.docker.com/_/postgres/
# and https://hub.docker.com/_/redis/

COPY requirements.txt /tmp/
COPY editable-requirements.txt /tmp/

ENV GOSU_VERSION 1.9
RUN set -x \
  && apt-get update && apt-get install -y --no-install-recommends ca-certificates wget && rm -rf /var/lib/apt/lists/* \
  && dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
  && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" \
  && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc" \
  && export GNUPGHOME="$(mktemp -d)" \
  && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
  && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
  && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
  && chmod +x /usr/local/bin/gosu \
  && gosu nobody true \
  && apt-get purge -y --auto-remove ca-certificates wget

# Install requisites for building Python packages.
# I need need to avoid error messages from pip freeze.
RUN set -x \
  && apt-get -y update \
  && apt-get install -y curl \
  && apt-get install -y git \
  && apt-get install -y libpq-dev \
  && apt-get install -y libjpeg62-turbo-dev \
  && apt-get install -y libopenjpeg-dev \
  && apt-get install -y libfreetype6-dev \
  && apt-get install -y libtiff5-dev \
  && apt-get install -y liblcms2-dev \
  && apt-get install -y libwebp-dev \
  && apt-get install -y postgresql-client-9.4 \
  && apt-get install -y python3-dev \
  && apt-get install -y python3-setuptools \
  && apt-get install -y python3-tk \
  && apt-get install -y tk8.6-dev

ENV PROJECT_NAME project
ENV PORT 8000
ENV POSTGRES_PORT 5432
ENV REDIS_HOST none
ENV REDIS_PORT 6379
ENV SETTINGS_MODULE local

RUN /usr/local/bin/pyvenv /root/.venv/django

RUN . /root/.venv/django/bin/activate \
  && curl https://bootstrap.pypa.io/get-pip.py | python \
  && pip install --upgrade pip \
  && pip install --requirement /tmp/requirements.txt

EXPOSE $PORT

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["development"]
