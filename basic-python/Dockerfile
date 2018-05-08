FROM python:3.6.5-slim-stretch as builder
WORKDIR /root

RUN set -e \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    git-core \
    ssh \
  && rm -rf /var/lib/apt/lists/*

ARG SSH_PRIVATE_KEY
RUN mkdir -p /root/.ssh/ \
  && echo "${SSH_PRIVATE_KEY}" > /root/.ssh/id_rsa \
  && chmod 600 /root/.ssh/id_rsa \
  && echo "StrictHostKeyChecking no " > /root/.ssh/config

# Private repositories can be cloned now so the following will work:
# pip install -e git://git.example.com/MyProject#egg=MyProject

COPY requirements.txt /root/requirements.txt

RUN python -m venv /env \
  && . /env/bin/activate \
  && pip install --upgrade pip \
  && pip install --no-cache-dir -r requirements.txt

FROM python:3.6.5-slim-stretch
LABEL maintainer="Alexis Bellido <a@zinibu.com>"
WORKDIR /root

COPY --from=builder /env /env
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

SHELL ["/bin/bash", "-c"]
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
