FROM python:3.6.5-slim-stretch

LABEL maintainer="Alexis Bellido <a@zinibu.com>"

COPY requirements.txt /root/requirements.txt
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

WORKDIR /root

SHELL ["/bin/bash", "-c"]
RUN python -m venv /env \
  && source /env/bin/activate \
  && pip install --upgrade pip \
  && pip install --no-cache-dir -r requirements.txt

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
